require_relative "jekyll_remote_plantuml_plugin/utils"
require_relative "jekyll_remote_plantuml_plugin/jekyll_remote_plantuml_plugin"
require_relative "jekyll_remote_plantuml_plugin/version"

Liquid::Template.register_tag("plantuml", JekyllRemotePlantUMLPlugin::Block)
