package com.dougmccune.subversion.events
{
	import flash.events.Event;

	/**
	 * Dispatched from the SVNClient when the data that came back from a request is a properly
	 * formatted XML response. If the data is not proper XML but is a String, then a StringResponseEvent
	 * is fired instead of the XMLResponseEvent.
	 */
	public class XMLResponseEvent extends Event
	{
		public static var XML_RESPONSE:String = "xmlResponse";
		
		/**
		 * The XML response from the server.
		 */
		public var xml:XML;
		
		public function XMLResponseEvent(type:String, xml:XML, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.xml = xml;
			
			super(type, bubbles, cancelable);
		}
		
		/**
		 * @private
		 */
		override public function clone():Event {
			return new XMLResponseEvent(type, xml, bubbles, cancelable);
		}
		
	}
}