# frozen_string_literal: true

class GZippedTar::Tar::WriteFile
  def self.call(writer, io, name, mode, &block)
    new(writer, io, name, mode).call(&block)
  end

  def initialize(writer, io, name, mode)
    @writer  = writer
    @io      = io
    @name    = name
    @mode    = mode
    @initial = io.pos
  end

  def call(&block)
    # placeholder for the header
    io.write GZippedTar::Tar::EMPTY_ROW

    block.call GZippedTar::Tar::RestrictedStream.new(io) if block

    writer.pad_rows size
    overwrite_header
  end

  private

  attr_reader :writer, :io, :name, :mode, :initial

  def overwrite_header
    current_position = io.pos
    io.pos = initial

    writer.write_header name, mode, :size => size

    io.pos = current_position
  end

  def size
    @size ||= io.pos - initial - GZippedTar::Tar::ROW_WIDTH
  end
end
