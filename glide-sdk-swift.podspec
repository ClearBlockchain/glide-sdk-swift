Pod::Spec.new do |spec|
    spec.name         = "glide-sdk-swift"
    spec.version      = "0.1.0"
    spec.summary      = "Glide SDK for iOS"
    spec.description  = "Glide SDK for iOS"
    spec.homepage     = "https://github.com/ClearBlockchain/glide-sdk-swift"
    spec.author             = { "author" => "GlideAPI" }
    spec.source       = { :git => "https://github.com/ClearBlockchain/glide-sdk-swift", :tag => "#{spec.version}" }
    spec.source_files  = "Sources/glide-sdk-swift/**/*.swift"
    spec.resource_bundles ={ "glide-sdk-swift" => ["Sources/PrivacyInfo.xcprivacy"]}
end
