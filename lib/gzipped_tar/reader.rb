# frozen_string_literal: true

require "stringio"

module GZippedTar
  class Reader
    def initialize(raw)
      @raw = raw
    end

    def read(path)
      result = nil
      reader.each { |entry| result = entry.read if entry.full_name == path }
      result
    end

    private

    attr_reader :raw

    def reader
      GZippedTar::Tar::Reader.new unzipped
    end

    def unzipped
      Zlib::GzipReader.new StringIO.new(raw, "r+b")
    end
  end
end
