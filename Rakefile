# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "cheddargetter_client"
  gem.homepage = "http://github.com/BrentW/cheddargetter_client"
  gem.license = "MIT"
  gem.summary = %Q{A ruby wrapper for the Cheddargetter API}
  gem.description = %Q{A more flexible solution for accessing the Cheddargetter API}
  gem.email = "brent.wooden@gmail.com"
  gem.authors = ["Brent Wooden"]
  # dependencies defined in Gemfile

  gem.add_dependency "httparty", ">= 0.10.0"
  gem.add_dependency "crack", ">= 0.3.2"
end
Jeweler::RubygemsDotOrgTasks.new
