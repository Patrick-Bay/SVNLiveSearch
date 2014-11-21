package com.dougmccune.subversion.requests
{
	import com.dougmccune.webdav.Report;
	
	/**
	 * Returns the revision number for the exact date that you request. If you don't
	 * send the exact right date string, however, no revision number will get sent back.
	 * 
	 * Limited documentation can be found here (relevant section appears below): 
	 * http://svn.collab.net/repos/svn/trunk/notes/webdav-protocol
	 * 
	 * dated-rev-report
	 * ----------------
	 * 
	 * Purpose: Get the revision associated with a particular date.
	 * 
	 * Target URL: VCC URL for repos.
	 * 
	 * Request:
	 * <S:dated-rev-report xmlns:S="svn:" xmlns:D="DAV:">
	 * 	<D:creationdate>2005-12-07T13:06:26.034802Z</D:creationdate>
	 * </S:dated-rev-report>
	 * 
	 * Response:
	 * <S:dated-rev-report xmlns:S="svn:" xmlns:D="DAV:">
	 * 	<D:version-name>4747</D:version-name>
	 * </S:dated-rev-report>
	 */
	public class SVNDatedRevReport extends Report
	{
		public function SVNDatedRevReport(dateString:String="")
		{
			var str:String = 	'<S:dated-rev-report xmlns:S="svn:" xmlns:D="DAV:">';
			str += 					'<D:creationdate>' + dateString + '</D:creationdate>';
			str += 				'</S:dated-rev-report>';

			super(str);
		}
	}
}