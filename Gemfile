source 'https://rubygems.org'

gemspec

group :console do
  gem 'pry'
end

group :test do
  gem 'rspec'
end

group :tools do
  gem 'rubocop'

  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-rubocop'

  platform :mri do
    gem 'mutant'
    gem 'mutant-rspec'
  end
end
