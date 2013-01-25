require 'crack'
require 'httparty'
require 'cgi' unless Object.const_defined?("CGI")

module Cheddargetter
  autoload :Client, "cheddargetter/client"
  autoload :Response,"cheddargetter/response"
end
