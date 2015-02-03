// UI Auotmation Docs - https://developer.apple.com/library/ios/documentation/DeveloperTools/Reference/UIAutomationRef/_index.html

#import "SnapshotHelper.js"

var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();

// Setting to initial orientation (not necessary unless taking screenshots in multiple orientations)
target.setDeviceOrientation(UIA_DEVICE_ORIENTATION_PORTRAIT);

target.delay(3)
captureLocalizedScreenshot("0-CuteScreen")

target.frontMostApp().tabBar().buttons()[1].tap();
target.delay(1)
captureLocalizedScreenshot("1-CuterScreen")

// Rotate to landscape
// target.setDeviceOrientation(UIA_DEVICE_ORIENTATION_LANDSCAPELEFT);

target.frontMostApp().tabBar().buttons()[2].tap();
target.delay(1)
captureLocalizedScreenshot("2-CutestScreen")