require "liquid"
require "digest"

module JekyllRemotePlantUMLPlugin
  class Block < Liquid::Block
    include Utils::Common
    include Utils::PlantUML
    include Utils::Encode

    FORMATS = %w[png svg].freeze
    CONFIG_OPTIONS = %i[
      provider
      format
      save_images_locally cache_dir
      div_class div_style
      img_class img_style img_id img_width img_height img_alt
    ].freeze
    TAG_OPTIONS = CONFIG_OPTIONS.dup.tap do |h|
      %i[provider save_images_locally cache_dir].each do |k|
        h.delete(k)
      end
    end.freeze
    DEFAULT_CONFIG_OPTIONS = {
      provider: "http://www.plantuml.com/plantuml",
      format: "svg",
      save_images_locally: false,
      cache_dir: "plantuml",
      div_class: "plantuml",
      img_class: "plantuml"
    }.freeze

    PARAMS_SYNTAX = /
        ([\w-]+)\s*=\s*
        (?:"([^"\\]*(?:\\.[^"\\]*)*)"|'([^'\\]*(?:\\.[^'\\]*)*)'|([\w.-]+))
      /x.freeze

    def initialize(tag_name, markup, _)
      super
      @markup = markup.strip
    end

    def render(context)
      content = super(context).strip
      encoded_content = encode(content)
      options = tag_options(context)

      check_format(options[:format])

      url = generate_url(options[:provider], encoded_content, options[:format])
      check_server(url, content)

      img_src_attr = options[:save_images_locally] ? img_local_src(context, encoded_content, url, options) : url
      prepare_html(img_src_attr, options)
    end

    private

    def tag_options(context)
      tag_options = parse_params(context)

      # delete unsupported options
      tag_options.each { |key, _| tag_options.delete(key) unless TAG_OPTIONS.include?(key) }

      # merge with config options
      configuration_options.merge(tag_options)
    end

    # rubocop:disable Metrics/MethodLength
    def parse_params(context)
      {}.tap do |params|
        @markup.scan(PARAMS_SYNTAX) do |key, d_quoted, s_quoted, variable|
          params[key] = if d_quoted
                          d_quoted.include?('\\"') ? d_quoted.gsub('\\"', '"') : d_quoted
                        elsif s_quoted
                          s_quoted.include?("\\'") ? s_quoted.gsub("\\'", "'") : s_quoted
                        elsif variable
                          context[variable]
                        end
        end
      end.transform_keys(&:to_sym)
    end
    # rubocop:enable Metrics/MethodLength

    def configuration_options
      @configuration_options ||= Jekyll.configuration({})["plantuml"].transform_keys(&:to_sym).tap do |conf|
        # delete unsupported options
        conf.each { |key, _| conf.delete(key) unless CONFIG_OPTIONS.include?(key) }

        # set defaults
        DEFAULT_CONFIG_OPTIONS.each { |key, value| conf[key] = value if conf[key].nil? }
      end
    end

    def img_local_src(context, encoded_content, url, options)
      # prepare source image path
      site = context.registers[:site]
      image_basename = "#{Digest::SHA1.hexdigest encoded_content}.#{options[:format]}"
      source_image_path = File.join(site.source, options[:cache_dir], image_basename)

      unless File.exist?(source_image_path)
        download_image(url, source_image_path)

        # make the image available in the destination directory
        site.static_files << Jekyll::StaticFile.new(site, site.source, options[:cache_dir], image_basename)
      end

      "/#{join_paths(site.baseurl, options[:cache_dir], image_basename)}"
    end

    def check_format(format)
      raise "Invalid PlantUML diagram format \"#{format}\"" unless FORMATS.include?(format)
    end

    def check_server(url, content)
      response = Net::HTTP.get_response(URI(url))
      return if response.is_a?(Net::HTTPSuccess)

      raise <<~TEXT
        The download of the PlantUml diagram image failed

        URL: #{url}

        === CONTENT START
        #{content}
        === CONTENT END

        === RESPONSE BODY START
        #{res.body}
        === RESPONSE BODY END
      TEXT
    end

    def prepare_html(img_src_attr, options)
      div_tag = ""
      div_tag += "<div#{prepare_optional_attrs_content("div_", options)}>"
      img_tag = "<img src=\"#{img_src_attr}\"#{prepare_optional_attrs_content("img_", options)} />"
      div_tag += "\n  #{img_tag}\n"
      "#{div_tag}</div>"
    end

    def prepare_optional_attrs_content(prefix, options)
      result = ""
      TAG_OPTIONS.each do |key|
        next if !key.to_s.start_with?(prefix) || options[key].nil? || options[key].empty?

        attribute_name = key.to_s.reverse.chomp(prefix.reverse).reverse
        attribute_value = options[key]

        result += " #{attribute_name}=\"#{attribute_value}\""
      end

      result
    end
  end
end
