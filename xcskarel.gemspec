Gem::Specification.new do |s|
  s.name                  = 'xcskarel'
  s.version               = '0.0.1'
  s.date                  = '2015-08-26'
  s.summary               = "Manage Xcode Server & Bots"
  s.description           = "Tool for managing your Xcode Server & Bot configurations"
  s.author                = "Honza Dvorsky"
  s.email                 = 'http://honzadvorsky.com'
  s.homepage              = 'http://rubygems.org/gems/xcskarel'
  s.license               = 'MIT'

  s.required_ruby_version = '>= 2.0.0'

  s.files                 = Dir["lib/**/*"]
  s.require_paths         = ["lib"]

  # dependencies
  s.add_dependency 'excon', '0.45.4' # http client
  s.add_dependency 'json', '1.8.3' # json parsing
  s.add_dependency 'logger', '1.2.8' # logging
  s.add_dependency 'colored', '1.2' # colored logging

  s.add_development_dependency 'pry', '0.10.1' # debugging
  
end

# http://guides.rubygems.org/make-your-own-gem/
