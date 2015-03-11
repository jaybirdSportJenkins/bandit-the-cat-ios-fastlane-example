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

## My Paths

### Before - [view here](https://github.com/RokkinCat/bandit-the-cat-ios-fastlane-example/blob/master/fastlane/Fastfile#L7)
```ruby
before_all do

  # Clean up
  system "(cd ../; (rm -f #{ENV['SCHEME']}.app.dSYM.zip) )"
  system "(cd ../; (rm -f #{ENV['SCHEME']}.ipa) )"

  # Increments build number of your project
  increment_build_number

  # Makes sure all cocoapods are up to date
  cocoapods

  # Runs unit tests
  # - argumnets passed as array of strings
  # - Docs on xctool (https://github.com/facebook/xctool)
  xctool ["-workspace #{ENV['WORKSPACE']}", "-scheme #{ENV['SCHEME']}"]

end
```

### Test - [view here](https://github.com/RokkinCat/bandit-the-cat-ios-fastlane-example/blob/master/fastlane/Fastfile#L26)
```ruby
lane :test do

  # Takes all screenshots for you (so magical)
  # - Configurations are in Snapfile
  # - Steps are defined in the snapshot.js
  snapshot

end
```

### Beta - [view here](https://github.com/RokkinCat/bandit-the-cat-ios-fastlane-example/blob/master/fastlane/Fastfile#L35)
```ruby
lane :beta do

  # Gets (and renews) provisioning profiles
  sigh

  # Builds IPA
  system "(cd ../; ( ipa build -s #{ENV['SCHEME']} -c Debug ) )"

  # Send to HockeyApp
  hockey({
    api_token: ENV['HOCKEYAPP_API_TOKEN'],
    ipa: "./#{ENV['SCHEME']}.ipa",
    notify: 1
  })

end
```

### Deploy - [view here](https://github.com/RokkinCat/bandit-the-cat-ios-fastlane-example/blob/master/fastlane/Fastfile#L52)
```ruby
lane :deploy do
  snapshot
  sigh
  system "(cd ../; ( ipa build -s #{ENV['SCHEME']} -c Release ) )"
  deliver :skip_deploy, :force
end
```

### Inhouse - [view here](https://github.com/RokkinCat/bandit-the-cat-ios-fastlane-example/blob/master/fastlane/Fastfile#L59)
```ruby
lane :inhouse do
  
  # sigh
  sigh

  # Builds IPA
  system "(cd ../; ( ipa build -s #{ENV['SCHEME']} -c Inhouse ) )"

  upload_to_s3({
    ipa_name: ENV['ipa_name'],
    scheme: ENV['SCHEME'],
    bundle_id: ENV['BUNDLE_ID'],
    s3_bucket: ENV['S3_BUCKET'],
    s3_access_key: ENV['S3_ACCESS_KEY'],
    s3_secret_access_key: ENV['S3_SECRET_ACCESS_KEY']
  })

end
```

### After - [view here](https://github.com/RokkinCat/bandit-the-cat-ios-fastlane-example/blob/master/fastlane/Fastfile#L80)
```ruby
after_all do |lane|

  # Create message for slack 
  message = nil
  case lane
  when :beta
    build_number = Actions.lane_context[ Actions::SharedValues::BUILD_NUMBER ]

    url = Actions.lane_context[ Actions::SharedValues::HOCKEY_DOWNLOAD_LINK ]
    build_info = Actions.lane_context[ Actions::SharedValues::HOCKEY_BUILD_INFORMATION ]

    message = "Deployed build #{build_number} of #{build_info['title']} to HockeyApp - #{url}"
  when :inhouse
    build_number = `(cd ../; xcrun agvtool what-version -terse)`.strip
    version_number = `(cd ../; xcrun agvtool what-marketing-version -terse1)`.strip
    version_name = "v#{version_number} (#{build_number})"

    url = Actions.lane_context[ Actions::SharedValues::UPLOAD_TO_S3_URL]
    message = "Deployed build #{version_name} to S3 - #{url}"
  end

  # Sebd nessage to slack
  if message
    slack({
     message: message,
     success: true,
    })
  end

end
```

## Travis

- Export inhouse.cer and inhouse.p12
- `travis encrypt "KEY_PASSWORD={password}" --add`
- `travis encrypt "ENCRYPTION_SECRET={encryption_secret}" --add`
- Encrypt inhouse.cer and inhouse.p12
```
openssl aes-256-cbc -k "{encryption_secret}" -in scripts/certs/inhouse.cer -out scripts/certs/inhouse.cer.enc -a
openssl aes-256-cbc -k "{encryption_secret}" -in scripts/certs/inhouse.p12 -out scripts/certs/inhouse.p12.enc -a
```