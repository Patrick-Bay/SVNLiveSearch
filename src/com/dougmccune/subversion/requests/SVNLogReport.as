package com.dougmccune.subversion.requests
{
	import com.dougmccune.webdav.Report;
	
	/**
	 * Retrieves an SVN revision history report. 
	 * 
	 * Limited documentation can be found here (relevant section appears below): 
	 * http://svn.collab.net/repos/svn/trunk/notes/webdav-protocol
	 * 
	 * log-report
	 * ----------
	 * 
	 * Purpose: Retrieve the log for a portion of the repository.
	 * 
	 * Target URL: Current baseline collection for a directory plus relative paths.
	 * 
	 * Example: REPORT /repos/test/!svn/bc/5/httpd/support
	 * 
	 * Request:
	 * <S:log-report xmlns:S="svn:">
	 * 	<S:start-revision>2</S:start-revision>
	 * 	<S:end-revision>2</S:end-revision>
	 * 	<S:limit>1</S:limit> (optional)
	 * 	<S:discover-changed-paths/> (optional)
	 * 	<S:strict-node-history/> (optional)
	 * 	<S:include-merged-revisions/> (optional)
	 * 	<S:revprop>REVPROP</S:revprop>... | <S:all-revprops/> | <S:no-revprops/>
	 * 		('revprop', 'all-revprops', and 'no-revprops' are all optional)
	 * 	<S:path></S:path>... (optional)
	 * </S:log-report>
	 * 
	 * Response:
	 * <?xml version="1.0" encoding="utf-8"?>
	 * <S:log-report xmlns:S="svn:" xmlns:D="DAV:">
	 * 	<S:log-item>
	 * 		<D:version-name>2</D:version-name>
	 * 		<S:creator-displayname>bob</S:creator-displayname>
	 * 		<S:date>2006-02-27T18:44:26.149336Z</S:date>
	 * 		<D:comment>Add doo-hickey</D:comment>
	 * 		<S:revprop name="REVPROP">value</S:revprop>... (optional)
	 * 		<S:has-children/> (optional)
	 * 		<S:added-path( copyfrom-path="PATH" copyfrom-rev="REVNUM">PATH</S:added-path>... (optional)
	 * 		<S:replaced-path( copyfrom-path="PATH" copyfrom-rev="REVNUM">PATH</S:replaced-path>... (optional)
	 * 		<S:deleted-path>PATH</S:deleted-path>... (optional)
	 * 		<S:modified-path>PATH</S:modified-path>... (optional)
	 * 	</S:log-item>
	 * 	...multiple log-items for each returned revision...
	 * </S:log-report>
	 */

	public class SVNLogReport extends Report
	{
		/**
		 * Limits the number of log items returned. If set to -1 no limit is sent and all
		 * items will be requested.
		 */
		public var limit:int = -1;
		
		/**
		 * Optional path for this report
		 */
		public var path:String = "";
		
		/**
		 * Not sure what this is for
		 */
		public var strictNodeHistory:Boolean = false;
		
		/**
		 * Not sure what this is for
		 */
		public var includeMergedRevisions:Boolean = false;
		
		/**
		 * Not sure what this is for
		 */
		public var allRevProps:Boolean = false;
		
		public function SVNLogReport(startRevision:int, endRevision:int=-1, includePathDetails:Boolean=false)
		{
			if(endRevision == -1) {
				endRevision = startRevision;
			}
			
			var svnLogString:String = 	'<?xml version="1.0" encoding="utf-8" ?>';
			svnLogString += 			'<S:log-report xmlns:S="svn:">';
			svnLogString += 				'<S:start-revision>' + startRevision + '</S:start-revision>';
			svnLogString += 				'<S:end-revision>'   + endRevision   + '</S:end-revision>'; 
			svnLogString +=					'<S:path>' + path + '</S:path>';
			
			if(includePathDetails)
				svnLogString += 			'<S:discover-changed-paths/>';
			
			if(strictNodeHistory)
				svnLogString += 			'<S:strict-node-history/>';
			
			if(includeMergedRevisions)
				svnLogString += 			'<S:include-merged-revisions/>';
			
			if(allRevProps)
				svnLogString +=				'<S:all-revprops/>';
			
			if(limit != -1)
				svnLogString += 			'<S:limit>' + limit + '</S:limit>';
			
			svnLogString += 			'</S:log-report>';

			super(svnLogString);
		}
		
		override protected function loadDefaultHeaders():void {
			//the default HTTP headers that httpclientlib adds to all 
			//requests includes Connection: close, but I found that to
			//be problematic with various SVN wedav installs (particularly
			//the one on opensource.adobe.com), so I've overridden this
			//loadDefaultHeaders function to not add any headers for this request
		}
		
	}
}