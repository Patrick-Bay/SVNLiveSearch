package com.dougmccune.webdav {
  
	import org.httpclient.HttpRequest;
  
	public class Propfind extends HttpRequest {
    
		public function Propfind(depth:int=1) {      
			super("PROPFIND");
			addHeader("Depth", String(depth));
		}
    
		override public function get hasRequestBody():Boolean {
			return false;
		}
    
 		override public function get hasResponseBody():Boolean {
			return true;
		}
	}
}