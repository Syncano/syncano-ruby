source 'https://rubygems.org'

gemspec

group :console do
  gem 'pry'
end

group :test do
  gem 'dotenv'
  gem 'rspec'
end

group :tools do
  gem 'rubocop', require: false

  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-rubocop'

  platform :mri do
    gem 'mutant'
    gem 'mutant-rspec'
  end
end
