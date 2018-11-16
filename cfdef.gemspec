# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cfdef/version'

Gem::Specification.new do |spec|
  spec.name          = 'cfdef'
  spec.version       = Cfdef::VERSION
  spec.authors       = ['winebarrel']
  spec.email         = ['sgwr_dts@yahoo.co.jp']

  spec.summary       = %q{Cfdef is a tool to manage CloudFront.}
  spec.description   = %q{Cfdef is a tool to manage CloudFront.}
  spec.homepage      = 'https://github.com/codenize-tools/cfdef'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'aws-sdk-cloudfront'
  spec.add_dependency 'diffy'
  spec.add_dependency 'dslh', '>= 0.3.6'
  spec.add_dependency 'term-ansicolor'
  spec.add_dependency 'parallel'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
