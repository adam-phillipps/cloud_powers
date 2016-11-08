$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'cloud_powers'
require 'cloud_powers/brain_func'
require 'cloud_powers/helpers'
require 'byebug'
require 'fileutils'
require 'json'
require 'ostruct'
require 'pathname'
Smash::CloudPowers::PROJECT_ROOT=Pathname.new(`pwd`.strip)
