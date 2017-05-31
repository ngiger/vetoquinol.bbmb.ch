source 'https://rubygems.org'

gem 'odba'
gem 'rake'
gem 'oga'
gem 'bbmb', '>= 2.2.8'

group :debugger do
  if RUBY_VERSION.match(/^1/)
    gem 'pry-debugger'
  else
    gem 'pry-byebug'
    gem 'pry-doc'
  end
end

group :test do
  gem 'minitest'
  gem 'flexmock'
  gem 'rspec'
  gem 'watir'
  gem 'watir-webdriver'
end
