$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'cloud_powers'
require 'byebug'
require 'fileutils'
require 'ostruct'
require 'pathname'
PROJECT_ROOT=Pathname.new(`pwd`.strip)
