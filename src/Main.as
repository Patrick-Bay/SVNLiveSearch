package  {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;	
	import flash.events.ProgressEvent;
	import com.bit101.components.*;
	import com.bit101.charts.*;
	import com.bit101.utils.*;
	//http://minimalcomps.googlecode.com/svn/trunk/src
	public dynamic class Main extends Sprite {		
		
		public var config:XML =
		<config>
		    <launchcmd>
		        @ECHO OFF
				@CLS
				%path%;
				svn.exe ls -R %repoURL%
			</launchcmd>
			<views>
				<main>
					<TextField x="5" y="10">Repository URL:</TextField>
		<InputText instance="repoURL" x="90" y="10" width="550">http://</InputText >
					<TextField x="5" y="30">Search file name:</TextField>
					<InputText instance="fileName" x="90" y="30" width="550"></InputText>
					<PushButton instance="searchButton" x="90" y="60" width="550">SEARCH</PushButton>
					<TextField instance="currentSearchName" x="90" y="80" width="550">CURRENT</TextField>
					<TextArea instance="results" x="50" y="110" width="600" height="500"></TextArea>
				</main>
			</views>
		</config>
		
		private var _searchProc:NativeProcess;
		
		public function Main():void {
			this.addEventListener(Event.ADDED_TO_STAGE, this.setDefaults);
		}		
		
		private function onSearchProgress(eventObj:ProgressEvent):void {			
			var newLine:String = _searchProc.standardOutput.readMultiByte(_searchProc.standardOutput.bytesAvailable, "iso-8895-1");
			newLine = newLine.split(String.fromCharCode(10)).join("");						
			this.analyzeSearchOutput(newLine);
			
		}
		
		private function analyzeSearchOutput(outText:String):void {
			var lines:Array = outText.split(String.fromCharCode(13));
			var searchFileName:String = this.fileName.text;
			for (var count:int = 0; count < lines.length; count++) {
				var currentLine:String = lines[count] as String;
				this.currentSearchName.text = currentLine;			
				if (currentLine.indexOf(searchFileName) > -1) {
					this.results.text += currentLine+String.fromCharCode(13);
				}
			}
		}
		
		private function onSearchClick(eventObj:MouseEvent):void {
			var launchCMDContents:String = String(this.config.launchcmd);			
			launchCMDContents = launchCMDContents.split("%repoURL%").join(this.repoURL.text);			
			var tmpDir:File = File.createTempDirectory();
			var cmdFile:File = tmpDir.resolvePath("svnls.cmd");			
			var executable:File = File.applicationDirectory.resolvePath("./bin_x86/svn.exe");
			launchCMDContents = launchCMDContents.split("%path%").join("PATH "+File.applicationDirectory.nativePath + "\\bin_x86");
			trace (launchCMDContents);
			//launchCMDContents = launchCMDContents.split("%svn.exe%").join(File.applicationDirectory.nativePath+"/bin_x86");
			//Create CMD file (safer with non-standard parameters than launching process directly)
			var fs:FileStream = new FileStream();
			fs.open(cmdFile, FileMode.WRITE);
			fs.writeMultiByte(launchCMDContents, "iso-8859-1");			
			fs.close();		
			//Launch CMD file
			var npInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			npInfo.workingDirectory = File.applicationDirectory;
			npInfo.executable = cmdFile;				
			_searchProc = new NativeProcess();
			_searchProc.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, this.onSearchProgress);
			this.results.text = "";
			_searchProc.start(npInfo);
			trace ("Started search...");
		}
		
		private function buildView(viewName:String):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, this.setDefaults);
			var viewDef:XML = this.findViewDef(viewName);
			var viewItems:XMLList = viewDef.children();
			for (var count:int = 0; count < viewItems.length(); count++) {
				var currentViewItem:XML = viewItems[count] as XML;				
				this.generateComponent(currentViewItem);
			}
			this.searchButton.addEventListener(MouseEvent.CLICK, this.onSearchClick);
		}
		
		private function generateComponent(componentDef:XML):void {			
			var componentClassName:String = componentDef.localName();
			switch (componentClassName) {
				case "TextField":
					try {
						var xPos:Number = Number(componentDef.@x);
					} catch (err:*) {
						xPos = 0;
					}
					try {
						var yPos:Number = Number(componentDef.@y);
					} catch (err:*) {
						yPos = 0;
					}
					try {
						var initText:String = componentDef.children().toString();
					} catch (err:*) {
						initText = "";
					}
					var tfComp:TextField = new TextField();
					var format:TextFormat = new TextFormat();
					tfComp.embedFonts = true;
					tfComp.selectable = false;
					tfComp.type = "dynamic";
					format.size = 8;
					format.font = "PF Ronda Seven";
					tfComp.defaultTextFormat = format;
					tfComp.x = xPos;
					tfComp.y = yPos;
					this.addChild(tfComp);
					tfComp.text = initText;
					try {
						var nameVal:String = String(componentDef.@instance);
						tfComp.name = nameVal;
						this[nameVal] = tfComp;
					} catch (err:*) {						
					}
					break;				
				case "InputText":
					try {
						var xPos:Number = Number(componentDef.@x);
					} catch (err:*) {
						xPos = 0;
					}
					try {
						var yPos:Number = Number(componentDef.@y);
					} catch (err:*) {
						yPos = 0;
					}
					try {
						var initText:String = componentDef.children().toString();
					} catch (err:*) {
						initText = "";
					}
					var itComp:InputText = new InputText(this, xPos, yPos, initText);
					try {
						var widthVal:Number = Number(componentDef.@width);
						if (widthVal>0) {
							itComp.width = widthVal;
						}
					} catch (err:*) {						
					}
					try {
						var heightVal:Number = Number(componentDef.@height);
						if (heightVal>0) {
							itComp.height = heightVal;
						}
					} catch (err:*) {						
					}
					try {
						var nameVal:String = String(componentDef.@instance);
						itComp.name = nameVal;
						this[nameVal] = itComp;
					} catch (err:*) {						
					}
					break;
				case "TextArea":
					try {
						var xPos:Number = Number(componentDef.@x);
					} catch (err:*) {
						xPos = 0;
					}
					try {
						var yPos:Number = Number(componentDef.@y);
					} catch (err:*) {
						yPos = 0;
					}
					try {
						var initText:String = componentDef.children().toString();
					} catch (err:*) {
						initText = "";
					}
					var taComp:TextArea = new TextArea(this, xPos, yPos, initText);
					try {
						var widthVal:Number = Number(componentDef.@width);
						if (widthVal>0) {
							taComp.width = widthVal;
						}
					} catch (err:*) {						
					}
					try {
						var heightVal:Number = Number(componentDef.@height);
						if (heightVal>0) {
							taComp.height = heightVal;
						}
					} catch (err:*) {						
					}
					try {
						var nameVal:String = String(componentDef.@instance);
						taComp.name = nameVal;
						this[nameVal] = taComp;
					} catch (err:*) {						
					}
					break;
				case "PushButton":
					try {
						var xPos:Number = Number(componentDef.@x);
					} catch (err:*) {
						xPos = 0;
					}
					try {
						var yPos:Number = Number(componentDef.@y);
					} catch (err:*) {
						yPos = 0;
					}
					try {
						var initText:String = componentDef.children().toString();
					} catch (err:*) {
						initText = "";
					}
					var butComp:PushButton = new PushButton(this, xPos, yPos, initText);
					try {
						var widthVal:Number = Number(componentDef.@width);
						if (widthVal>0) {
							butComp.width = widthVal;
						}
					} catch (err:*) {						
					}
					try {
						var heightVal:Number = Number(componentDef.@height);
						if (heightVal>0) {
							butComp.height = heightVal;
						}
					} catch (err:*) {						
					}
					try {
						var nameVal:String = String(componentDef.@instance);
						butComp.name = nameVal;
						trace ("Naming button: " + nameVal);
						this[nameVal] = butComp;
					} catch (err:*) {						
					}
					break;
				default: break;
			}
		}
		
		private function findViewDef(viewName:String):XML {
			var viewsNode:XML = this.config.child("views")[0] as XML;
			for (var count:int = 0; count < viewsNode.children().length(); count++) {
				var currentNode:XML = viewsNode.children()[count] as XML;
				var nodeName:String = currentNode.localName() as String;
				if (nodeName == viewName) {
					return (currentNode);
				}
			}
			return (null);
		}
		
		private function setDefaults(eventObj:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, this.setDefaults);			
			this.buildView("main");
		}		
		
	}
	
}