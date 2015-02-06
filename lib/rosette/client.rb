# encoding: UTF-8

require 'rosette/client/cli'
require 'rosette/client/repo'

module Rosette
  module Client
    autoload :Api,           'rosette/client/api'
    autoload :Terminal,      'rosette/client/terminal'
    autoload :Writer,        'rosette/client/writer'
    autoload :Commands,      'rosette/client/commands'
    autoload :Response,      'rosette/client/response'
    autoload :HashResponse,  'rosette/client/response'
    autoload :ArrayResponse, 'rosette/client/response'
  end
end
