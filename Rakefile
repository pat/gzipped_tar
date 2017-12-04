# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)
task :default => :spec

if RUBY_VERSION.to_f >= 2.1
  require "rubocop/rake_task"
  RuboCop::RakeTask.new(:rubocop)

  Rake::Task["default"].clear if Rake::Task.task_defined?("default")
  task :default => [:rubocop, :spec]
end
