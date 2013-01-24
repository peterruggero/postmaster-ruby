require 'rubygems'
require 'rake/testtask'
require 'rcov/rcovtask'

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

Rcov::RcovTask.new do |t|
  t.test_files = FileList['test/test*.rb']
  #t.verbose = true     # uncomment to see the executed command
end


task :default => [:test]

