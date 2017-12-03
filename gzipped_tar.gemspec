# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "gzipped_tar"
  spec.version       = "0.0.1"
  spec.authors       = ["Pat Allan"]
  spec.email         = ["pat@freelancing-gods.com"]

  spec.summary       = "In-memory reading/writing of .tar.gz files"
  spec.homepage      = "https://github.com/pat/gzipped_tar"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |file|
    file.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |file| File.basename(file) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rspec",   "~> 3.7"
  spec.add_development_dependency "rubocop", "~> 0.51.0"
end
