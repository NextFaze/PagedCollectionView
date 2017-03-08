#
# Be sure to run `pod lib lint PagedCollectionView.podspec' to ensure this is a
# valid spec before submitting.

Pod::Spec.new do |s|
  s.name             = 'PagedCollectionView'
  s.version          = '0.1.0'
  s.summary          = 'A centered paged collection view with page controls'
  s.description      = <<-DESC
This collection view allows cells that are smaller than the
view itself to be centered, and snaps them to the center to
achieve paging. There is also an optional page control.
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
