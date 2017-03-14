#
# Be sure to run `pod lib lint PagedCollectionView.podspec' to ensure this is a
# valid spec before submitting.

Pod::Spec.new do |s|
  s.name             = 'PagedCollectionView'
  s.version          = '0.2'
  s.summary          = 'A centered paged collection view'
  s.description      = <<-DESC
This collection view renders cells as centered pages, that
snap to the center when scrolling and allow the next and
previous cell edges to be seen.
                       DESC

  s.homepage         = 'https://github.com/NextFaze/PagedCollectionView'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ricsantos' => 'rsantos@nextfaze.com' }
  s.source           = { :git => 'https://github.com/Nextfaze/PagedCollectionView.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/nextfaze'

  s.ios.deployment_target = '9.0'

  s.source_files = 'PagedCollectionView/Classes/**/*'
  
  # s.resource_bundles = {
  #   'PagedCollectionView' => ['PagedCollectionView/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
