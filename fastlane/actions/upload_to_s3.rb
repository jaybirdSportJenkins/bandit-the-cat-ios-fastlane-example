require 'aws-sdk'

module Fastlane
  module Actions
    module SharedValues
      UPLOAD_TO_S3_URL = :UPLOAD_TO_S3_URL
    end

    class UploadToS3Action
      def self.run(params)
        options = params[0]

        ipa_name = options[:ipa_name]
        scheme = options[:scheme]
        bundle_id = options[:bundle_id]
        s3_bucket = options[:s3_bucket]
        s3_access_key = options[:s3_access_key]
        s3_secret_access_key = options[:s3_secret_access_key]
        
        # Gets build number stuff
        build_number = `xcrun agvtool what-version -terse`.strip
        version_number = `xcrun agvtool what-marketing-version -terse1`.strip
        build_id = 

        directory = "v#{version_number}b#{build_number}"

        ipa_url = "https://s3.amazonaws.com/#{s3_bucket}/#{directory}/#{scheme}.ipa"
        plist_url = "https://s3.amazonaws.com/#{s3_bucket}/#{directory}/#{scheme}.plist"
        index_url = "https://s3.amazonaws.com/#{s3_bucket}/index.html"

        # Upload to S3
        s3 = AWS::S3.new(
            access_key_id: s3_access_key,
            secret_access_key: s3_secret_access_key
        )
        bucket = s3.buckets[s3_bucket]
        bucket_file_name = "#{directory}/#{scheme}.ipa"

        bucket.objects.create(bucket_file_name, File.open("./#{scheme}.ipa", "r"), :acl => :public_read) 

        plist_file_name = "#{directory}/#{scheme}.plist"
        bucket.objects.create(plist_file_name, plist(ipa_url, scheme, bundle_id, version_number), :acl => :public_read) 

        version_name = "v#{version_number} (#{build_number})"
        index_file_name = "index.html"
        bucket.objects.create(index_file_name, indexhtml(plist_url, scheme, version_name, build_number), :acl => :public_read)         

        Actions.lane_context[SharedValues::UPLOAD_TO_S3_URL] = index_url
      end

      def self.plist(ipa_url, scheme, bundle_id, version_number)
        return <<-eos
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>items</key>
  <array>
    <dict>
      <key>assets</key>
      <array>
        <dict>
          <key>kind</key>
          <string>software-package</string>
          <key>url</key>
          <string>#{ipa_url}</string>
        </dict>
      </array>
      <key>metadata</key>
      <dict>
        <key>bundle-identifier</key>
        <string>#{bundle_id}</string>
        <key>bundle-version</key>
        <string>#{version_number}</string>
        <key>kind</key>
        <string>software</string>
        <key>title</key>
        <string>#{scheme}</string>
      </dict>
    </dict>
  </array>
</dict>
</plist>
        eos
      end

      def self.indexhtml(plist_url, scheme, version_name, build_number)
        return <<-eos
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>#{scheme}</title>

  </head>

  <body>

    <div class="site-wrapper">

      <div class="site-wrapper-inner">

        <div class="cover-container">

         <div class="masthead clearfix">
            <div class="inner">
              <h3 class="masthead-brand">#{scheme}</h3>
            </div>
          </div>

          <div class="inner cover">
            <h1 class="cover-heading"></h1>
            <p class="lead"></p>
            <p class="lead">
              <a href="itms-services://?action=download-manifest&url=itms-services://?action=download-manifest&url=#{plist_url}" id="text" class="btn btn-lg btn-default">Install #{scheme} #{version_name}</a>
            </p>
          </div>

          <div class="mastfoot">
            <div class="inner">
              <p></p>
            </div>
          </div>

        </div>

      </div>

    </div>
    
  </body>
</html>
        eos
      end

    end
  end
end

