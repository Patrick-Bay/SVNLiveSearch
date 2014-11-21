package com.dougmccune.webdav
{
	import flash.utils.ByteArray;
	
	import org.httpclient.HttpRequest;

	public class Report extends HttpRequest
	{
		/**
		 * A generic REPORT request that can contain a body. Specific reports should extend this
		 * class and pass in the report body as a string in the constructor.
		 */
		public function Report(body:String="")
		{
			super("REPORT");

			_body = new ByteArray();
			
			if(body != null) {
				ByteArray(_body).writeUTFBytes(body);
			}
			
			_body.position = 0;
			
			_header.replace("Content-Type", "text/xml; charset=\"utf-8\"");
      		_header.replace("Content-Length", String(body.length));      
		}
		
		override public function get hasRequestBody():Boolean {
	      return true;
	    }
	    
	    override public function get hasResponseBody():Boolean {
	      return true;
	    }
	}
}