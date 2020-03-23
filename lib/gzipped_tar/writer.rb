# frozen_string_literal: true

require "stringio"

module GZippedTar
  class Writer
    def add(path, contents)
      writer.add_file(path, 0o644) { |input| input.write contents }
    end

    def output
      io = binary_io

      gzip_writer = Zlib::GzipWriter.new io
      gzip_writer.write input_io.string
      gzip_writer.close

      io.string
    end

    private

    def binary_io
      io = StringIO.new "".dup, "r+b"
      io.set_encoding "BINARY"
      io
    end

    def input_io
      @input_io ||= StringIO.new
    end

    def writer
      @writer ||= GZippedTar::Tar::Writer.new input_io
    end
  end
end
