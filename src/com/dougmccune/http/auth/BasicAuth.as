package com.dougmccune.http.auth
{
	import mx.utils.Base64Encoder;
	
	import org.httpclient.HttpRequest;
	
	public class BasicAuth
	{
		public function BasicAuth(user:String, password:String)
		{
			this.user = user;
			this.password = password;
		}
		
		public var user:String;
		public var password:String;
		
		/**
		 * Applies this authorization to a HttpRequest by setting the appropriate headers.
		 */
		public function apply(request:HttpRequest):void {
			var base64util:Base64Encoder = new Base64Encoder();
			
			//basic authentication just uses a simple base 64 encoding of the username and password
			//note that this is not a secure encoding, you passwords are easily decoded if you use
			//basic authentication over non-secure HTTP
			base64util.encode(user + ":" + password);
			
			var base64:String = base64util.toString();
			
			request.header.replace("Authorization", "Basic " + base64);
		}

	}
}