require 'bundler'
Bundler::GemHelper.install_tasks

desc "Run all specs"
task :spec do
  Dir['spec/*_spec.rb'].each do |spec|
    #puts "Running #{spec}..."
    load spec
  end
end
