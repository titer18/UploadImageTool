Pod::Spec.new do |s|
  s.name             = 'UploadImageTool'
  s.version          = '1.0'
  s.summary          = '压缩并上传图片到七牛'

  #添加第三方依赖
  s.dependency 'Qiniu'
  s.dependency 'AFNetworking'

  s.description      = <<-DESC
压缩并上传图片到七牛。
                       DESC

  s.homepage         = 'https://github.com/titer18/UploadImageTool'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'titer' => 'zhaohong1991@hotmail.com' }
  s.source           = { :git => 'https://github.com/titer18/UploadImageTool.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'UploadImageTool/Classes/**/*.{h,m}'
  s.public_header_files = 'UploadImageTool/Classes/**/*.h'

end
