package com.dougmccune.subversion
{
	[Bindable]
	public class SVNRevision
	{
		public var revisionNumber:Number;
		
		public var creatorName:String;
		public var comment:String;
		
		public var date:Date;
		
		public var modified:Array 	/* of SVNPath */;
		public var added:Array 		/* of SVNPath */;
		public var replaced:Array 	/* of SVNPath */;
		public var deleted:Array 	/* of SVNPath */;
	}
}