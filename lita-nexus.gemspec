Gem::Specification.new do |spec|
  spec.name          = "lita-nexus"
  spec.version       = "0.1.8"
  spec.authors       = ["Wang, Dawei"]
  spec.email         = ["dwang@entertainment.com"]
  spec.description   = "Lita Nexus Operations"
  spec.summary       = "Nexus server related operations"
  spec.homepage      = "https://github.com/af6140/lita-nexus"
  spec.license       = "Apache-2.0"
  spec.metadata      = { "lita_plugin_type" => "handler" }

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "lita", ">= 4.7"
  #support ruby v 2.1.x
  spec.add_runtime_dependency "rack", "~> 1.6"
  spec.add_runtime_dependency "nexus_cli", "~> 4.1"
  spec.add_runtime_dependency "nokogiri"
  spec.add_runtime_dependency "versionomy"

  spec.add_development_dependency "bundler", "~> 1.3"
  #spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake"
  #spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rspec", ">= 3.0.0"
  spec.add_development_dependency "docker-api"
end
