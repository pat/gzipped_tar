# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "gzipped_tar"
  spec.version       = "0.1.2"
  spec.authors       = ["Pat Allan"]
  spec.email         = ["pat@freelancing-gods.com"]

  spec.summary       = "In-memory reading/writing of .tar.gz files"
  spec.homepage      = "https://codeberg.org/patallan/gzipped_tar"
  spec.license       = "MIT"

  spec.required_ruby_version = ">= 2.7"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir["lib/**/*"] + %w[CODE_OF_CONDUCT.md LICENSE.txt README.md]

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
