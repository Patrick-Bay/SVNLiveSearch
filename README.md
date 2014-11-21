SVNLiveSearch
=============

Remote SVN repository search tool.

### To compile and run SVNLiveSearch ###

1. Download and install FlashDevelop: http://www.flashdevelop.org/
	- Install at least "Flex + Air SDK" and "Adobe AIR" in the AS3 section of AppMan installer application.
2. Clone, checkout, or download and unzip the source code: https://github.com/Patrick-Bay/SVNLiveSearch
3. From the main FlashDevelop menu choose *Project -> Open Project...* and open the *SVNLiveSearch.as3proj* file.
4. Type CTRL-ENTER, press the F5 key, or select *Project -> Test Project*

### To build a standalone Windows executable ###

1. Follow steps 1 to 3 above to install FlashDevelop, get the source code, and open the project file.
2. Run FlashDevelop.
3. If not already available, open the Project Manager panel by selecting *View -> Project Manager* from the menu.
4. In the "bat" folder in the Project Manager panel find *CreateCertificate.bat*, right-click on it, and select *Execute*.
5. When step 4 completes, find *PackageApp.bat* in the Project Manager, right-click on it, and select *Execute*.
6. In the opened command window select option 1 (Native .EXE with captive runtime) by typing 1 and ENTER.

The standalone executable will be built to the *air\standalone* output folder. 
This version can run from any location and the "standalone" folder may be renamed, but its contents must be distributed as built.
