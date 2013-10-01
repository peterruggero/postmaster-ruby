require 'rubygems'
require 'rake/testtask'

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.test_files = FileList['test/test_*.rb'].exclude('test/test_helper.rb')
  test.verbose = true
end

if ENV['CI_SERVER']
  if RUBY_VERSION < "1.9"
    require 'ci/reporter/rake/test_unit'
    task :test => 'ci:setup:testunit'
  else
    require 'ci/reporter/rake/minitest'
    task :test => 'ci:setup:minitest'
  end
  ENV['coverage'] = '1'
end

if ENV['coverage'] and RUBY_VERSION < "1.9"
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |t|
    t.test_files = FileList['test/test_*.rb'].exclude('test/test_helper.rb')
    #t.verbose = true     # uncomment to see the executed command
  end
end


task :default => [:test]
