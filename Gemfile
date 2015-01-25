source 'https://rubygems.org'

gemspec

gem 'faraday'

group :console do
  gem 'pry'
end

group :test do
  gem 'dotenv'
  gem 'rspec'
  gem 'webmock'
end

group :tools do
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-rubocop'

  gem 'rubocop', require: false

  platform :mri do
    gem 'mutant'
    gem 'mutant-rspec'
  end
end
