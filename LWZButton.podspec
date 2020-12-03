Pod::Spec.new do |s|

s.name = 'LWZButton'

s.version = '1.0.0'

s.summary = 'An enlarged button in iOS.'

s.homepage = 'http://baidu.com' 

s.authors = { 'lwz' => 'heywenzhong@163.com' }

s.source = { :git => 'https://github.com/heywenzhong/LWZBtn.git', :tag => s.version }

s.requires_arc = true

s.license = 'MIT'

s.ios.deployment_target = '9.0'

s.source_files = 'LWZButton/*'
end