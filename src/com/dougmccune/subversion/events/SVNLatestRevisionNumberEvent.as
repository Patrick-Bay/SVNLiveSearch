package com.dougmccune.subversion.events
{
	import flash.events.Event;

	public class SVNLatestRevisionNumberEvent extends Event
	{
		public static var LATEST_REVISION_NUMBER_LOADED:String = "lastestRevisionNumberLoaded";
		
		/**
		 * The revision number. Duh.
		 */
		public var revisionNumber:Number;
		
		public function SVNLatestRevisionNumberEvent(revision:Number, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.revisionNumber = revision;
			
			super(LATEST_REVISION_NUMBER_LOADED, bubbles, cancelable);
		}
		
		/**
		 * @private
		 */
		override public function clone():Event {
			return new SVNLatestRevisionNumberEvent(revisionNumber, bubbles, cancelable);
		}
		
	}
}