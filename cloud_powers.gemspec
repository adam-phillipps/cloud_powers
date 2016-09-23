# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cloud_powers/version'

Gem::Specification.new do |spec|
  spec.required_ruby_version  =      '~> 2.3.0'
  spec.name                   =       'cloud_powers'
  spec.version                =       CloudPowers::VERSION
  spec.author                 =       'Adam Phillipps'
  spec.email                  =       'adam.phillipps@gmail.com'
  spec.summary                =       %q{Cloud providers wrapper.  Currently only AWS is supported.}
  spec.description            =       <<-EOF
    CloudPowers is a wrapper around AWS and other cloud services.
    This wrapper was developed specifically for the Brain project
    but can be used in any other ruby project.
  EOF
  spec.homepage               =       'https://smashanalytics.atlassian.net/wiki/display/SB/Cloud+Powers'
  spec.license                =       'MIT'

  spec.files                  =      `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir                 =      'exe'
  spec.executables            =      spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths          =      ['lib']

  spec.add_runtime_dependency       'activesupport-core-ext', '~> 4'
  spec.add_runtime_dependency       'aws-sdk', '~> 2'
  spec.add_runtime_dependency       'dotenv', '~> 2.1'
  spec.add_runtime_dependency       'httparty', '~> 0.14'
  spec.add_runtime_dependency       'rubyzip', '~> 1.2'
  spec.add_runtime_dependency       'zip-zip', '~> 0.3'

  spec.add_development_dependency   'bundler', '~> 1.12'
  spec.add_development_dependency   'byebug', '~> 9'
  spec.add_development_dependency   'rake', '~> 10.0'
  spec.add_development_dependency   'rspec', '~> 3.0'
end
