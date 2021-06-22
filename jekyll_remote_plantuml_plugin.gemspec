require_relative "lib/jekyll_remote_plantuml_plugin/version"

Gem::Specification.new do |spec|
  spec.name = "jekyll_remote_plantuml_plugin"
  spec.version = JekyllRemotePlantUMLPlugin::VERSION
  spec.authors = ["Alexey Igrychev"]
  spec.email = ["alexey.igrychev@flant.com"]

  spec.summary = "Jekyll plugin that allows including local/remote PlantUML diagrams into your pages, works only with" \
                 " an external PlantUML server (http://www.plantuml.com/plantuml by default) — PlantUML jar installed" \
                 " locally not required."
  spec.homepage = "https://github.com/flant/jekyll_remote_plantuml_plugin"
  spec.license = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.6.3")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir["lib/**/*.rb"]
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "jekyll", "~> 3.9"
  spec.add_runtime_dependency "liquid", "~> 4.0"
end
