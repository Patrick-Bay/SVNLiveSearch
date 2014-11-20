package  {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;	
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;	
	import flash.events.ProgressEvent;
	import flash.events.NativeProcessExitEvent;
	import com.bit101.components.*;
	import com.bit101.charts.*;
	import com.bit101.utils.*;
	//http://minimalcomps.googlecode.com/svn/trunk/src
	public dynamic class Main extends Sprite {		
		
		public var config:XML =
		<config>
		    <launchcmd>@ECHO OFF
@CLS
PATH %exepath%;
CD %exepath%
svn.exe ls -R %repoURL%
			</launchcmd>
			<views>
				<main>
					<TextField x="5" y="10">Repository URL:</TextField>
					<InputText instance="repoURL" x="90" y="10" width="550">http://</InputText >
					<TextField x="5" y="30">Search file name:</TextField>
					<InputText instance="fileName" x="90" y="30" width="550"></InputText>
					<CheckBox instance="caseSensitiveToggle" x="90" y="50" width="550">Case Sensitive</CheckBox>
					<PushButton instance="searchButton" x="90" y="70" width="550">SEARCH</PushButton>					
					<TextArea instance="results" x="10" y="110" width="680" height="500"></TextArea>
					<TextArea instance="searchProgressHistory" x="10" y="650" width="680" height="130"></TextArea>					
				</main>
			</views>
		</config>
		
		private var _searchProc:NativeProcess;
		private var _outputBuffer:String = null;
		private var _searchProgressHistoryLength:uint = 0;
		public var maxSearchProgressHistLength:uint = 1000;
		
		public function Main():void {
			this.addEventListener(Event.ADDED_TO_STAGE, this.setDefaults);
		}		
		
		private function onSearchProgress(eventObj:ProgressEvent):void {			
			var newLine:String = _searchProc.standardOutput.readMultiByte(_searchProc.standardOutput.bytesAvailable, "iso-8895-1");
			this.skipToEnd(this.searchProgressHistory);
			this.analyzeSearchOutput(newLine);
			
		}
		
		private function stopSearch():void {
			if (_searchProc != null) {
				_searchProc.exit(true);
				this.onSearchProcessExit(null);				
			}
		}
		
		private function onSearchProcessExit(eventObj:NativeProcessExitEvent):void {
			_searchProc.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, this.onSearchProgress);
			_searchProc.removeEventListener(NativeProcessExitEvent.EXIT, this.onSearchProcessExit);
			_searchProc.closeInput();
			_searchProc = null;
			this.resetSearchButton();
		}
		
		private function scrollLoop(eventObj:Event):void {	
			var currentScrollPos:Number = this.searchProgressHistory.scrollbar.value;
			var minScrollPos:Number = this.searchProgressHistory.scrollbar.minimum;
			var maxScrollPos:Number = this.searchProgressHistory.scrollbar.maximum;
			try {
				this.searchProgressHistory.scrollbar.goDown();				
			} catch (err:*) {			
			}
			try {
				if (!_searchProc.running) {
					if (currentScrollPos>=maxScrollPos) {
						this.removeEventListener(Event.ENTER_FRAME, this.scrollLoop);
					}//if
				}
			} catch (err:*) {
				
			}
		}
		
		private function analyzeSearchOutput(outText:String):void {
			if (_outputBuffer != null) {
				outText = _outputBuffer + outText;
				_outputBuffer = "";
			}//if
			if (this._searchProgressHistoryLength > maxSearchProgressHistLength) {
				this.searchProgressHistory.text = "";
				_searchProgressHistoryLength = 0;
			}
			var lines:Array = outText.split(String.fromCharCode(13));
			var searchFileName:String = this.fileName.text;
			for (var count:int = 0; count < (lines.length-1); count++) {
				var currentLine:String = lines[count] as String;
				currentLine = currentLine.split(String.fromCharCode(10)).join("");
				currentLine = currentLine.split(String.fromCharCode(13)).join("");
				this.searchProgressHistory.text += currentLine+String.fromCharCode(13);
				this._searchProgressHistoryLength++;
				if (this.searchMatch(searchFileName, currentLine)) {
					this.results.text += currentLine+String.fromCharCode(13);
				}//if				
			}//for
			if (lines[lines.length-1].indexOf(String.fromCharCode(13)) < 0) {
				currentLine = lines[lines.length - 1];
				currentLine = currentLine.split(String.fromCharCode(10)).join("");
				currentLine = currentLine.split(String.fromCharCode(13)).join("");
				_outputBuffer = currentLine;
			}//if
		}
		
		private function searchMatch(searchPattern:String, compareString:String):Boolean {
			var localCompareStr:String = new String(compareString);
			var localSearchStr:String = new String(searchPattern);
			if (!this.caseSensitiveSearch) {
				localCompareStr = localCompareStr.toLowerCase();
				localSearchStr = localSearchStr.toLowerCase();
			}
			if (localCompareStr.indexOf(localSearchStr) > -1) {
				return (true);
			}//if
			return (false);
		}
		
		private function skipToEnd(taInstance:TextArea):void {
			try {
				taInstance.scrollbar.value = taInstance.scrollbar.maximum;
			} catch (err:*) {				
			}
		}
		
		private function resetSearchButton():void {
			this.searchButton.removeEventListener(MouseEvent.CLICK, this.onStopClick);
			this.searchButton.addEventListener(MouseEvent.CLICK, this.onSearchClick);
			this.searchButton.label = "SEARCH";
		}
		
		private function onStopClick(eventObj:MouseEvent):void {
			this.stopSearch();
			this.resetSearchButton();
			this.skipToEnd(this.searchProgressHistory);
		}
		
		private function onSearchClick(eventObj:MouseEvent):void {
			this.stopSearch();
			this.searchButton.removeEventListener(MouseEvent.CLICK, this.onSearchClick);
			this.searchButton.addEventListener(MouseEvent.CLICK, this.onStopClick);
			this.searchButton.label = "STOP SEARCH";
			var launchCMDContents:String = String(this.config.launchcmd);			
			launchCMDContents = launchCMDContents.split("%repoURL%").join(this.repoURL.text);			
			var tmpDir:File = File.createTempDirectory();
			var cmdFile:File = tmpDir.resolvePath("svnls.cmd");			
			var executable:File = File.applicationDirectory.resolvePath("./bin_x86/svn.exe");
			launchCMDContents = launchCMDContents.split("%exepath%").join(File.applicationDirectory.nativePath + "\\bin_x86");
			//Create CMD file (safer with non-standard parameters than launching process directly)
			var fs:FileStream = new FileStream();
			fs.open(cmdFile, FileMode.WRITE);
			fs.writeMultiByte(launchCMDContents, "iso-8859-1");			
			fs.close();		
			//Launch CMD file
			var npInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			npInfo.workingDirectory = tmpDir;
			npInfo.executable = cmdFile;				
			_searchProc = new NativeProcess();
			_searchProc.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, this.onSearchProgress);
			_searchProc.addEventListener(NativeProcessExitEvent.EXIT, this.onSearchProcessExit);
			this.results.text = "";
			this.searchProgressHistory.text = "Searching...";
			this.addEventListener(Event.ENTER_FRAME, this.scrollLoop);
			try {
				_searchProc.start(npInfo);
				
			} catch (err:*) {
				this.results.text = "NativeProcess threw an error: "+err;
			}			
		}
		
		public function get caseSensitiveSearch():Boolean {
			try {
				return (this.caseSensitiveToggle.selected);
			} catch (err:*) {
				return (false);
			}
			return (false);
		}
		
		private function buildView(viewName:String):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, this.setDefaults);
			var viewDef:XML = this.findViewDef(viewName);
			var viewItems:XMLList = viewDef.children();
			for (var count:int = 0; count < viewItems.length(); count++) {
				var currentViewItem:XML = viewItems[count] as XML;				
				this.generateComponent(currentViewItem);
			}			
			this.results.editable = false;
			this.searchProgressHistory.editable = false;
			if (!NativeProcess.isSupported) {
				this.searchButton.enabled = false;
				this.results.text = "SVNLiveSearch can't continue because NativeProcess is not supported.\n";
				this.results.text += "This application must be compiled as a native Windows executable (not an .air file)";
			} else {
				this.searchButton.enabled = true;
				this.searchButton.addEventListener(MouseEvent.CLICK, this.onSearchClick);
			}
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
					tfComp.autoSize = TextFieldAutoSize.LEFT;
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
						xPos = Number(componentDef.@x);
					} catch (err:*) {
						xPos = 0;
					}
					try {
						yPos = Number(componentDef.@y);
					} catch (err:*) {
						yPos = 0;
					}
					try {
						initText = componentDef.children().toString();
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
						nameVal = String(componentDef.@instance);
						itComp.name = nameVal;
						this[nameVal] = itComp;
					} catch (err:*) {						
					}
					break;
				case "TextArea":
					try {
						xPos = Number(componentDef.@x);
					} catch (err:*) {
						xPos = 0;
					}
					try {
						yPos = Number(componentDef.@y);
					} catch (err:*) {
						yPos = 0;
					}
					try {
						initText = componentDef.children().toString();
					} catch (err:*) {
						initText = "";
					}
					var taComp:TextArea = new TextArea(this, xPos, yPos, initText);
					try {
						widthVal = Number(componentDef.@width);
						if (widthVal>0) {
							taComp.width = widthVal;
						}
					} catch (err:*) {						
					}
					try {
						heightVal = Number(componentDef.@height);
						if (heightVal>0) {
							taComp.height = heightVal;
						}
					} catch (err:*) {						
					}
					try {
						nameVal = String(componentDef.@instance);
						taComp.name = nameVal;
						this[nameVal] = taComp;
					} catch (err:*) {						
					}
					break;
				case "PushButton":
					try {
						xPos = Number(componentDef.@x);
					} catch (err:*) {
						xPos = 0;
					}
					try {
						yPos = Number(componentDef.@y);
					} catch (err:*) {
						yPos = 0;
					}
					try {
						initText = componentDef.children().toString();
					} catch (err:*) {
						initText = "";
					}
					var butComp:PushButton = new PushButton(this, xPos, yPos, initText);
					try {
						widthVal = Number(componentDef.@width);
						if (widthVal>0) {
							butComp.width = widthVal;
						}
					} catch (err:*) {						
					}
					try {
						heightVal = Number(componentDef.@height);
						if (heightVal>0) {
							butComp.height = heightVal;
						}
					} catch (err:*) {						
					}
					try {
						nameVal = String(componentDef.@instance);
						butComp.name = nameVal;						
						this[nameVal] = butComp;
					} catch (err:*) {						
					}
					break;
				case "CheckBox":
					try {
						xPos = Number(componentDef.@x);
					} catch (err:*) {
						xPos = 0;
					}
					try {
						yPos = Number(componentDef.@y);
					} catch (err:*) {
						yPos = 0;
					}
					var checked:Boolean = false;
					try {
						var checkedStr:String = String(componentDef.@checked);
						if (checkedStr.toLowerCase() == "true") {
							checked = true;
						}//if
					} catch (err:*) {						
					}
					try {
						initText = componentDef.children().toString();
					} catch (err:*) {
						initText = "";
					}
					var cbComp:CheckBox = new CheckBox(this, xPos, yPos, initText);
					if (checked) {
						cbComp.selected = true;
					} else {
						cbComp.selected = false;
					}//else
					try {
						widthVal = Number(componentDef.@width);
						if (widthVal>0) {
							cbComp.width = widthVal;
						}
					} catch (err:*) {						
					}
					try {
						heightVal = Number(componentDef.@height);
						if (heightVal>0) {
							cbComp.height = heightVal;
						}
					} catch (err:*) {						
					}
					try {
						nameVal = String(componentDef.@instance);
						cbComp.name = nameVal;						
						this[nameVal] = cbComp;
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