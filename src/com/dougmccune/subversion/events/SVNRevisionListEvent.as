package com.dougmccune.subversion.events
{
	import flash.events.Event;

	public class SVNRevisionListEvent extends Event
	{
		public static var REVISIONS_LOADED:String = "revisionsLoaded";
		
		/**
		 * A list of SVNRevision objects.
		 */
		public var revisions:Array;
		
		public function SVNRevisionListEvent(type:String, revisions:Array=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.revisions = revisions;
			
			super(type, bubbles, cancelable);
		}
		
		/**
		 * @private
		 */
		override public function clone():Event {
			return new SVNRevisionListEvent(type, revisions, bubbles, cancelable);
		}
		
	}
}