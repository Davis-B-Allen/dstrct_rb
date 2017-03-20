# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "dstrct"
  spec.version       = '1.0'
  spec.authors       = ["Davis Allen"]
  spec.email         = ["davis.b.allen@gmail.com"]
  spec.summary       = %q{Short command-line game based on gerrymandering}
  spec.description   = %q{A short command-line game based on gerrymandering}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = ['lib/dstrct.rb']
  spec.executables   = ['bin/dstrct']
  spec.test_files    = ['test/test_dstrct.rb']
  spec.require_paths = ["lib"]
end
