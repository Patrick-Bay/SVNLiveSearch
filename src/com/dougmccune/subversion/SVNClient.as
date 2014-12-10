package com.dougmccune.subversion
{
	import com.adobe.net.URI;
	import com.adobe.utils.StringUtil;
	import com.dougmccune.http.HTTPStatusCodes;
	import com.dougmccune.http.auth.BasicAuth;
	import com.dougmccune.subversion.events.DataResponseEvent;
	import com.dougmccune.subversion.events.SVNLatestRevisionNumberEvent;
	import com.dougmccune.subversion.events.SVNRevisionListEvent;
	import com.dougmccune.subversion.events.StringResponseEvent;
	import com.dougmccune.subversion.events.XMLResponseEvent;
	import com.dougmccune.subversion.requests.SVNLogReport;
	import com.dougmccune.subversion.util.SVNReportResponseParser;
	import com.dougmccune.webdav.Propfind;
	import com.dougmccune.webdav.WebDavStatusCodes;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.ByteArray;
	
	import org.httpclient.HttpClient;
	import org.httpclient.HttpRequest;
	import org.httpclient.HttpResponse;
	import org.httpclient.Log;
	import org.httpclient.events.HttpDataEvent;
	import org.httpclient.events.HttpResponseEvent;
	 import org.httpclient.events.HttpListener;

	[Event(name="revisionsLoaded", type="com.dougmccune.subversion.events.SVNRevisionListEvent")]
	[Event(name="latestRevisionNumberLoaded", type="com.dougmccune.subversion.events.SVNLatestRevisionNumberEvent")]
	
	public class SVNClient extends HttpClient
	{
		
		public function SVNClient(username:String="", password:String ="", proxy:URI=null)
		{
			this.username = username;
			this.password = password;
			
			super(proxy);
			
			addEventListener(HttpResponseEvent.COMPLETE, responseCompleteHandler);
			addEventListener(HttpDataEvent.DATA, dataHandler);
		}
		
		/**
		 * If specified, basic HTTP authentication will be used.
		 */
		public var username:String;
		
		/**
		 * If specified, basic HTTP authentication will be used.
		 */
		public var password:String;
		
		/**
		 * @private
		 * 
		 * Keep track of the last request we made, in case we get a redirect, so we can send it again
		 * to the redirected URL.
		 */
		private var lastRequest:HttpRequest;
		
		/**
		 * @private
		 * 
		 * Keep track of the last URI too, since that's not included in the HttpRequest object.
		 */
		private var lastURI:URI;
		
		/**
		 * Local ByteArray to store partial data while we are receiving chunked responses.
		 */
		private var data:ByteArray;
		
		override public function request(uri:URI, request:HttpRequest, timeout:int = 60000, listener:HttpListener = null):void {
			lastRequest = request;
			lastURI = uri;
			
			if(username != null && username != "" && password != null && password != "") {
				new BasicAuth(username, password).apply(request);
			}
			
			super.request(uri, request, timeout);
		}
		
		/**
		 * @private
		 * 
		 * Keep track of the bytes in our data buffer until we receive a complete event.
		 */
		private function dataHandler(event:HttpDataEvent):void {
			if(data == null) {
				data = new ByteArray();
			}
			
			data.writeBytes(event.bytes, 0, event.bytes.length);
		}
		
		private function responseCompleteHandler(event:HttpResponseEvent):void {
			switch(event.response.code) {
				case HTTPStatusCodes.MOVED_PERMANENTLY:
				case HTTPStatusCodes.TEMPORARY_REDIRECT:
					handleRedirectResponse(event.response);
					break;
					
				case HTTPStatusCodes.UNAUTHORIZED:
					//TODO: add some better handling, or at least some kind of event
					break;
				
				case HTTPStatusCodes.FORBIDDEN:
					//TODO: add some better handling, or at least some kind of event
					break;
				
				case HTTPStatusCodes.OK:
				case WebDavStatusCodes.MULTI_STATUS:
					handleOKResponse(event.response);
					break;
					
				default:
					trace(event.response.message);
					break;
			}	
		}
		
		/**
		 * @private
		 * 
		 * Dispatches an XMLResponseEvent if the response is valid XML. If the response
		 * is a string but not valid XML then a StringResponseEvent is dispatched instead.
		 * 
		 * Regardless, a DataResponseEvent is always dispatched with the raw bytes of the response.
		 */
		private function handleOKResponse(response:HttpResponse):void {
			if(data != null) {
				data.position = 0;
				
				var string:String = data.readUTFBytes(data.bytesAvailable);
				
				try {
					var xml:XML = new XML(string);
					
					Log.debug(xml.toXMLString());
					
					dispatchEvent(new XMLResponseEvent(XMLResponseEvent.XML_RESPONSE, xml));
				}
				catch(e:Error) {
					if(StringUtil.trim(string) != "") {
						Log.debug(string);
						dispatchEvent(new StringResponseEvent(StringResponseEvent.STRING_RESPONSE, string));
					}
				}
				
				dispatchEvent(new DataResponseEvent(DataResponseEvent.DATA_RESPONSE, data));
				
				data = null;	
			}
		}
		
		/**
		 * @private
		 * 
		 * Automatically resend a new request to the new location. Re-uses the last HttpRequest object.
		 */
		private function handleRedirectResponse(response:HttpResponse):void {
			var newLocation:String = StringUtil.trim(response.header.getValue("Location"));
			request(new URI(newLocation), lastRequest);
		}
		
		/**
		 * Sends a request for the last revision in the revision history. 
		 * 
		 * When the revision is returned from the server, a SVNRevisionsListEvent will be dispatched and 
		 * will include the detailed SVNRevision item in the event's revisions Array.
		 */
		public function getLatestRevision(url:String, includePathDetails:Boolean=false):void {
			getLatestRevisions(url, 1, includePathDetails);
		}
		
		/**
		 * Get the specified number of latest revisions. This method will first load the latest revision number from the 
		 * repository, then use the latest rev number to request the number of entries you specify.
		 * 
		 * When the revisions are returned from the server, a SVNRevisionsListEvent will be dispatched and 
		 * will include the detailed SVNRevision items in the event's revisions Array.
		 */
		public function getLatestRevisions(url:String, number:Number, includePathDetails:Boolean=false):void {
			addEventListener(SVNLatestRevisionNumberEvent.LATEST_REVISION_NUMBER_LOADED, 
				
				function(event:SVNLatestRevisionNumberEvent):void {
					(event.target as IEventDispatcher).removeEventListener(event.type, arguments.callee)                             
					event.stopImmediatePropagation();
					getRevisions(url, event.revisionNumber - number + 1, event.revisionNumber, includePathDetails);
				}
				
			, false, 999, false);
			
			getLatestRevisionNumber(url);
		}
		
		/**
		 * Gets all revisions from the repository. Warning: this could take a long time, depending on the size of your repo.
		 * 
		 * When the revisions are returned from the server, a SVNRevisionsListEvent will be dispatched and 
		 * will include the detailed SVNRevision items in the event's revisions Array.
		 */
		public function getAllRevisions(url:String, includePathDetails:Boolean=false):void {
			addEventListener(SVNLatestRevisionNumberEvent.LATEST_REVISION_NUMBER_LOADED, 
				
				function(event:SVNLatestRevisionNumberEvent):void {
					(event.target as IEventDispatcher).removeEventListener(event.type, arguments.callee)                             
					event.stopImmediatePropagation();
					getRevisions(url, 0, event.revisionNumber, includePathDetails);
				}
				
			);
			
			getLatestRevisionNumber(url);
		}
		
		/**
		 * Get an exact range of revisions. 
		 * 
		 * When the revisions are returned from the server, a SVNRevisionsListEvent will be dispatched and 
		 * will include the detailed SVNRevision items in the event's revisions Array.
		 */
		public function getRevisions(url:String, start:Number, end:Number, includePathDetails:Boolean = false):void {
			addEventListener(XMLResponseEvent.XML_RESPONSE, logReportResponseHandler);
			
			var req:SVNLogReport = new SVNLogReport(start, end, includePathDetails);
			request(new URI(url), req);
		}
		
		/**
		 * Gets the latest revision umber from the repository. When the revision number is returned,
		 * a SVNLatestRevisionNumberEvent will be dispatched with the latest revision number.
		 */
		public function getLatestRevisionNumber(url:String):void {
			addEventListener(XMLResponseEvent.XML_RESPONSE, propFindForRevNumberHandler);
			
			var req:Propfind = new Propfind(0);
			request(new URI(url), req);
		}
		
		/**
		 * @private
		 * 
		 * When we get a log report response back we parse it into SVNReport items and dispatch a result event.
		 */
		private function logReportResponseHandler(event:XMLResponseEvent):void {
			removeEventListener(XMLResponseEvent.XML_RESPONSE, logReportResponseHandler);
			
			var revisions:Array = SVNReportResponseParser.parseLogReport(event.xml);
			
			dispatchEvent(new SVNRevisionListEvent(SVNRevisionListEvent.REVISIONS_LOADED, revisions));
		}
		
		/**
		 * When we get back the PROPFIND request we sent to load the latest revision number we extract
		 * the revision number and dispatch a result event.
		 */
		private function propFindForRevNumberHandler(event:XMLResponseEvent):void {
			removeEventListener(XMLResponseEvent.XML_RESPONSE, propFindForRevNumberHandler);
			
			var revNumber:Number = SVNReportResponseParser.getRevNumberFromPropFind(event.xml);
			dispatchEvent(new SVNLatestRevisionNumberEvent(revNumber));
		}
	}
}