$:.push File.expand_path('../lib', __FILE__)

require 'changed/version'

Gem::Specification.new do |s|
  s.name        = 'changed'
  s.version     = Changed::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Kevin Sylvestre']
  s.email       = ['kevin@clutter.com']
  s.homepage    = 'https://github.com/clutter/changed'
  s.summary     = 'Provides insights into what changed.'
  s.description = '⏱'
  s.license     = 'MIT'

  s.files = Dir['{app,db,lib}/**/*', 'LICENSE', 'Rakefile', 'README.md']

  s.required_ruby_version = '> 2.6.0'

  s.add_dependency 'rails'
  s.add_dependency 'request_store'

  s.add_development_dependency 'brakeman'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'byebug'
  s.add_development_dependency 'factory_bot_rails'
  s.add_development_dependency 'pg'
  s.add_development_dependency 'rspec_junit_formatter'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'shoulda-matchers'
  s.add_development_dependency 'simplecov'
end
