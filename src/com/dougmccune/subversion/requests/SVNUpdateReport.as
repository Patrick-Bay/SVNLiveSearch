package com.dougmccune.subversion.requests
{
	import com.dougmccune.webdav.Report;
	
	public class SVNUpdateReport extends Report
	{
		public function SVNUpdateReport(url:String, targetRevision:Number, entryRevision:Number)
		{
			var svnLogString:String = 	'<S:update-report xmlns:S="svn:">';
			svnLogString +=					'<S:src-path>' + url + '</S:src-path>';
			svnLogString += 				'<S:target-revision>' + targetRevision + '</S:target-revision>';
			svnLogString +=					'<S:entry rev="' + entryRevision + '"  start-empty="true"></S:entry>';
			svnLogString +=				'</S:update-report>';

			super(svnLogString);
		}
	}
}