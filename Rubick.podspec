Pod::Spec.new do |s|
  s.name         = "Rubick"
  s.version      = "0.0.1"
  s.summary      = "A simple and easy to use iOS library for tracking network."
  s.description  = <<-DESC
		Rubick is a simple and easy to use iOS library for tracking network.
                   DESC

  s.homepage     = "https://github.com/cloay/Rubick"

  s.license      = "MIT"


  s.author             = { "cloay" => "shangrody@gmail.com" }
  s.platform     = :ios, "7.0"



  s.source       = { :git => "https://github.com/cloay/Rubick.git", :tag => s.version }
  s.source_files  = "*.{h,m}","Log","Network","Swizzled"

end
