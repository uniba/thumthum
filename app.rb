require 'bundler'
Bundler.require
require './lib/tool_cli'

ToolCli.start(ARGV)
