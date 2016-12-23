$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'cloud_powers'
require 'cloud_powers/helpers'
require 'cloud_powers/stubs/aws_stubs'
require 'byebug'
require 'fileutils'
require 'json'
require 'ostruct'
require 'pathname'
Smash::CloudPowers::PROJECT_ROOT=Pathname.new(`pwd`.strip)
