$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'cloud_powers'
require 'byebug'
require 'fileutils'
require 'json'
require 'ostruct'
require 'pathname'
# Just for good measure, we'll set the project root.  If Zenv weren't able to
# find it some other way, it'll find this and it helps give everything a common
# starting point for files etc.
Smash::CloudPowers::PROJECT_ROOT=Pathname.new(`pwd`.strip)
