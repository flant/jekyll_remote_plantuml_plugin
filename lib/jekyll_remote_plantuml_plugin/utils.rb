require "open-uri"
require "zlib"

module JekyllRemotePlantUMLPlugin
  module Utils
    module Common
      def download_image(url, dest_path)
        dest_dir = File.dirname(dest_path)
        FileUtils.mkdir_p(dest_dir) unless File.directory?(dest_dir)

        uri = URI.parse(url)
        uri.open do |f|
          File.open(dest_path, "wb") do |file|
            file << f.read
          end
        end
      end
    end

    module Encode
      def encode(content)
        encoded = content.force_encoding("utf-8")
        encoded = Zlib::Deflate.new(nil, -Zlib::MAX_WBITS).deflate(encoded, Zlib::FINISH)
        encode64(encoded)
      end

      def encode64(content)
        length = content.length
        ind = 0
        out = ""

        while ind < length
          i1 = ind + 1 < length ? content[ind + 1].ord : 0
          i2 = ind + 2 < length ? content[ind + 2].ord : 0
          out += append3bytes(content[ind].ord, i1, i2)
          ind += 3
        end

        out
      end

      # rubocop:disable Metrics/AbcSize
      def append3bytes(bit1, bit2, bit3)
        c1 = bit1 >> 2
        c2 = ((bit1 & 0x3) << 4) | (bit2 >> 4)
        c3 = ((bit2 & 0xF) << 2) | (bit3 >> 6)
        c4 = bit3 & 0x3F
        encode6bit(c1 & 0x3F).chr +
          encode6bit(c2 & 0x3F).chr +
          encode6bit(c3 & 0x3F).chr +
          encode6bit(c4 & 0x3F).chr
      end
      # rubocop:enable Metrics/AbcSize

      # rubocop:disable Naming/MethodParameterName
      def encode6bit(b)
        return (48 + b).chr if b < 10

        b -= 10
        return (65 + b).chr if b < 26

        b -= 26
        return (97 + b).chr if b < 26

        b -= 26
        return "-" if b.zero?

        b == 1 ? "_" : "?"
      end
      # rubocop:enable Naming/MethodParameterName
    end

    module PlantUML
      def generate_url(provider, encoded_content, format)
        join_paths(provider, format, encoded_content).to_s
      end

      def join_paths(*paths, separator: "/")
        paths = paths.compact.reject(&:empty?)
        last = paths.length - 1
        paths.each_with_index.map do |path, index|
          expand_path(path, index, last, separator)
        end.join
      end

      def expand_path(path, current, last, separator)
        path = path[1..] if path.start_with?(separator) && current.zero?
        path = [path, separator] unless path.end_with?(separator) || current == last
        path
      end
    end
  end
end
