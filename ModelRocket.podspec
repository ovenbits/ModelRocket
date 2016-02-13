Pod::Spec.new do |s|
  s.name             = "ModelRocket"
  s.version          = "1.2.4"
  s.license          = "MIT"
  s.summary          = "An iOS framework for creating JSON-based models. Written in Swift."
  s.homepage         = "https://github.com/ovenbits/ModelRocket"
  s.author           = { "Jonathan Landon" => "jonathan.landon@ovenbits.com" }
  s.source           = { :git => "https://github.com/ovenbits/ModelRocket.git", :tag => s.version.to_s }
  s.platform         = :ios, '8.0'
  s.requires_arc     = true
  s.source_files     = ['Sources/*.swift', 'Sources/*.h']
end
