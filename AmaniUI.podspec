Pod::Spec.new do |s|
  s.name         = "AmaniUI"
  s.version      = "1.1.9"
  s.license      = { :type => "Copyright", :text => "\t\t\t\t\t\t\t\t\t\t\t\t\t\tCopyright 2022\n\t\t\t\t\t\t\t\t\t\t\t\t\t\tAmani Ai AŞ.\n" }
  s.swift_versions = "5.0"
  s.requires_arc = true
  s.homepage     = "http://www.amani.ai/"
  s.authors      = { "Amani Ai" => "admin@amani.ai" }
  s.summary      = "Amani-SDK v3 interface looks like v1."
  s.description  = "The Amani Software Development kit (SDK) provides you complete steps to perform eKYC. This package gives you a UI for v1 on v3 SDK."
  s.source       = { :path => "." }
  s.source_files = "AmaniUI/**/*.{h,m,swift}", "AmaniUI/**/*.{h,m,swift,xib}"
  s.resources    = "AmaniUI/**/Assets/**/*.*"
  s.documentation_url = "https://documentation.amani.ai"
  s.platform     = :ios, "13.0"
  s.pod_target_xcconfig = { "OTHER_LDFLAGS" => "-weak_framework CryptoKit -weak_framework CoreNFC -weak_framework CryptoTokenKit" }
  s.dependency "lottie-ios", "~> 4.4.1"
  s.dependency "AmaniSDK", "~> 3.4"
end

