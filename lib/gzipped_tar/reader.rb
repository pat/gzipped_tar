# frozen_string_literal: true

require "stringio"
require "rubygems/package"

module GZippedTar
  class Reader
    def initialize(raw)
      @raw = raw
    end

    def read(path)
      result = reader.detect { |entry| entry.full_name == path }
      result && result.read
    ensure
      reader.rewind
    end

    private

    attr_reader :raw

    def reader
      @reader ||= Gem::Package::TarReader.new unzipped
    end

    def unzipped
      Zlib::GzipReader.new StringIO.new(raw, "r+b")
    end
  end
end
