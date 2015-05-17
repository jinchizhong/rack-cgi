# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/cgi/version'

Gem::Specification.new do |spec|
  spec.name          = "rack-cgi"
  spec.version       = Rack::Cgi::VERSION
  spec.authors       = ["Chizhong Jin"]
  spec.email         = ["jinchizhong@kingsoft.com"]

  spec.summary       = 'A rack middleware that can call CGI in rack'
  spec.description   = 'A rack middleware that can call CGI in rack'
  spec.homepage      = 'http://rubygems.org/gems/rack-cgi'
  spec.license       = 'BSD'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'rake'
  spec.add_runtime_dependency 'childprocess'

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency 'test-unit'
  spec.add_development_dependency 'rake-test'
end
