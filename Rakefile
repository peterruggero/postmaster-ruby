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

if RUBY_VERSION < "1.9"
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'lib' << 'test'
    test.test_files = FileList['test/test_*.rb'].exclude('test/test_helper.rb')
    test.rcov_opts = %w{--exclude gems\/}
    #test.verbose = true     # uncomment to see the executed command
  end
end

if ENV['coverage'] and RUBY_VERSION < "1.9"
  task :default => [:rcov]
else
  task :default => [:test]
end
