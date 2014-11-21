package com.dougmccune.subversion.events
{
	import flash.events.Event;
	import flash.utils.ByteArray;

	public class DataResponseEvent extends Event
	{
		static public var DATA_RESPONSE:String = "dataResponse";
		
		/**
		 * The raw bytes returned in the server response.
		 */
		public var data:ByteArray;
		
		public function DataResponseEvent(type:String, data:ByteArray, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.data = data;
			
			super(type, bubbles, cancelable);
		}
		
		/**
		 * @private
		 */
		override public function clone():Event {
			return new DataResponseEvent(type, data, bubbles, cancelable);
		}
		
	}
}