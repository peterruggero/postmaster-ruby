require 'rubygems'
require 'rake/testtask'

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.test_files = FileList['test/test_*.rb'].exclude('test/test_helper.rb')
  test.verbose = true
end

if ENV['coverage'] and RUBY_VERSION < "1.9"
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |t|
    t.test_files = FileList['test/test_*.rb'].exclude('test/test_helper.rb')
    #t.verbose = true     # uncomment to see the executed command
  end
end


task :default => [:test]
