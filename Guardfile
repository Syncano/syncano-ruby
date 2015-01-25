guard :rspec, cmd: 'bundle exec rspec' do
  require 'guard/rspec/dsl'
  dsl = Guard::RSpec::Dsl.new(self)

  # Feel free to open issues for suggestions and improvements

  # RSpec files
  rspec = dsl.rspec
  watch("spec/spec_helper.rb") { rspec.spec_dir }
  watch("spec/**/*_spec.rb") { rspec.spec_dir }
  watch(rspec.spec_files)

  # Ruby files
  ruby = dsl.ruby
  dsl.watch_spec_files_for(ruby.lib_files)

  watch(ruby.lib_files) { rspec.spec_dir }
end

# guard :rubocop do
# watch(%r{.+\.rb$})
# watch(%r{(?:.+/)?\.rubocop\.yml$}) { |m| File.dirname(m[0]) }
# end
