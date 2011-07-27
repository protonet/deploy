require 'bundler'
Bundler::GemHelper.install_tasks

desc "Run all tests"
task :test do
  Dir['spec/*_spec.rb'].each do |spec|
    #puts "Running #{spec}..."
    load spec
  end
end
