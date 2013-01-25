require 'httparty'
require 'cgi' unless Object.const_defined?("CGI")

module Cheddargetter
  autoload :Client, File.expand_path("lib/cheddargetter/client.rb")
  autoload :Response, File.expand_path("lib/cheddargetter/response.rb")
end
