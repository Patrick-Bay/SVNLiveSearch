package com.dougmccune.subversion.util
{
	import com.adobe.utils.DateUtil;
	import com.dougmccune.subversion.SVNPath;
	import com.dougmccune.subversion.SVNRevision;
	
	import flash.utils.Dictionary;
	
	import mx.utils.StringUtil;
	
	public class SVNReportResponseParser
	{
		/**
		 * Parses the result of a PROPFIND http request and extracts the current version number.
		 * This is used to get the latest revision # when first checking an SVN repo.
		 */
		public static function getRevNumberFromPropFind(xml:XML):Number {
			xml = deNamespace(xml.toString());
			
			var revisionNumber:Number =  Number(xml.response.propstat.prop.descendants("version-name"));
			return revisionNumber;
		}
		
		/**
		 * Converts the XML from a SVN log report to an Array of SVNRevision items.
		 */
		public static function parseLogReport(xml:XML):Array {
			xml = deNamespace(xml.toString());
			
			var logItems:XMLList = xml.children();
			var n:int = logItems.length();
			
			var revisions:Array= [];
			
			for(var i:int=0; i<n; i++) {
				var logItem:XML = logItems[i];
				
				var revision:SVNRevision = new SVNRevision();
				revision.revisionNumber = Number(logItem.descendants('version-name'));
				revision.creatorName = logItem.descendants('creator-displayname');
				revision.comment = StringUtil.trim(logItem.comment);
				
				revision.modified 	= generatePaths( logItem.descendants("modified-path") );
				revision.added 		= generatePaths( logItem.descendants("added-path") );
				revision.replaced 	= generatePaths( logItem.descendants("replaced-path") );
				revision.deleted 	= generatePaths( logItem.descendants("deleted-path") );
				
				var dateString:String = logItem.date;
				if(dateString != "") {
					revision.date = DateUtil.parseW3CDTF(logItem.date);
				}
				
				revisions.push(revision);
			}
			
			return revisions;
		}
		
		private static function generatePaths(list:XMLList):Array {
			var array:Array = [];
			
			var n:int = list.length();
			for(var i:int=0; i<n; i++) {
				var pathItem:SVNPath = new SVNPath();
				
				var pathXML:XML = list[i];
				
				pathItem.path = pathXML.toString();
				pathItem.copiedFromPath = pathXML.attribute("copyfrom-path");
				pathItem.copiedFromRev = Number(pathXML.attribute("copyfrom-rev"));
				
				array.push(pathItem);
			}
			
			return array;
		}
		
		/**
		 * Helper function to remove the namespace crap from a block of XML. Sometimes it's just
		 * easier to wipe out xml namespaces instead of dealing with them when traversing.
		 */
		public static function deNamespace(xml:String):XML {
			var xmlString:String = xml;
			var xmlnsPattern:RegExp = new RegExp("<[a-z]+:", "gi");
			var namespaceRemovedXML:String = xmlString.replace(new RegExp("<\/[a-z]+:", "gi"), "</");
			namespaceRemovedXML = namespaceRemovedXML.replace(new RegExp("<[a-z]+:", "gi"), "<");
			
			return new XML(namespaceRemovedXML);
		}
	}
}