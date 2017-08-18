Pod::Spec.new do |s|
    s.name         = "RMPageView"
    s.version      = "1.0.0"
    s.summary      = "pageView"
    s.homepage     = "https://github.com/raomengchen/RMPageView"
    s.license      = "MIT"
    s.authors      = {"raomeng" => "raomeng915@163.com"}
    s.platform     = :ios, "7.0"
    s.source       = {:git => "https://github.com/raomengchen/RMPageView.git", :tag => s.version}
    s.source_files = "RMPageView/*.{h,m}"
    s.requires_arc = true
end