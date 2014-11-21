package com.dougmccune.subversion.events
{
	import flash.events.Event;
	import flash.utils.ByteArray;

	/**
	 * Dispatched from the SVNClient if the server returns a String (but not valid XML).
	 */
	public class StringResponseEvent extends Event
	{
		static public var STRING_RESPONSE:String = "stringResponse";
		
		/**
		 * The string returned from the server.
		 */
		public var string:String
		
		public function StringResponseEvent(type:String, string:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.string = string;
			
			super(type, bubbles, cancelable);
		}
		
		/**
		 * @private
		 */
		override public function clone():Event {
			return new StringResponseEvent(type, string, bubbles, cancelable);
		}
		
	}
}