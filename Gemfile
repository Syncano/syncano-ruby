source 'https://rubygems.org'

gemspec

group :console do
  gem 'pry'
end

group :test do
  gem 'dotenv'
  gem 'rspec'
  gem 'webmock'
  gem 'shoulda-matchers', require: false
  gem 'rspec-prof', git: 'https://github.com/sinisterchipmunk/rspec-prof.git'
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
