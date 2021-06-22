module JekyllRemotePlantUMLPlugin
  class Block < Liquid::Block
    def initialize(_, markup, _)
      super
      @params = {}
    end

    def render(context)
      super(context).strip
    end
  end
end
