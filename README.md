# fastlane example with Bandit The Cat

## My Additions
- Gemfile
  - Manage all my lane dependencies - dotenv, Shenzen, AWS, etc.
- fastlane/.env
  - Allows me to store varialbes in a `.env` file
  - None of my credential or API keys are sitting in the lane logic
  - Makes reusing my lanes in other projects easier (only need a new `.env`)
  - I can include `.env` in my `.gitignore` file so no one else has my credentials

## Fastlane 
- [Fastfile](https://github.com/RokkinCat/bandit-the-cat-ios-fastlane-example/blob/master/fastlane/Fastfile) - define your lanes (test, beta, deploy, inhouse, etc.)
- [actions](https://github.com/RokkinCat/bandit-the-cat-ios-fastlane-example/tree/master/fastlane/actions) - create custom actions for your lanes (upload to S3, upload through FTP, send a text through Twilio, etc.)

## Snapshot
- Used to take screenshots across all/any devices
- [Snapfile](https://github.com/RokkinCat/bandit-the-cat-ios-fastlane-example/blob/master/fastlane/Snapfile) - define your snapshot configurations
- [snapsho.js](https://github.com/RokkinCat/bandit-the-cat-ios-fastlane-example/blob/master/fastlane/snapshot.js) - define the steps using UI Automation to run through your app and take screenshots at certain points
- [SnapshowHelper.js](https://github.com/RokkinCat/bandit-the-cat-ios-fastlane-example/blob/master/fastlane/SnapshotHelper.js) - helpers for your UI Automation 
- [screenshots](https://github.com/RokkinCat/bandit-the-cat-ios-fastlane-example/tree/master/fastlane/screenshots) - the output directory for you screenshots

## Deliver
- Used to send builds (TestFlight, App Store)
- [Deliverfile](https://github.com/RokkinCat/bandit-the-cat-ios-fastlane-example/blob/master/fastlane/Deliverfile) - define your deliver configurations
- [metadata.json](https://github.com/RokkinCat/bandit-the-cat-ios-fastlane-example/blob/master/fastlane/deliver/metadata.json) - define your App Store data
