# frozen_string_literal: true

#--
# Original source is copyright (C) 2004 Mauricio Julio Fernández Pradier
# This file has been copied and adapted to avoid reliance on differing
# behaviour across versions of rubygems, and to handle nil header values at
# the end of a file.
#++

class GZippedTar::Tar::Reader
  include Enumerable

  ##
  # Creates a new TarReader on +io+ and yields it to the block, if given.

  def self.new(io)
    reader = super

    return reader unless block_given?

    begin
      yield reader
    ensure
      reader.close
    end

    nil
  end

  # Creates a new tar file reader on +io+ which needs to respond to #pos,
  # #eof?, #read, #getc and #pos=
  def initialize(io)
    @io       = io
    @init_pos = io.pos
  end

  # Close the tar file
  def close; end

  # Iterates over files in the tarball yielding each entry
  def each
    return enum_for __method__ unless block_given?

    until @io.eof?
      header = GZippedTar::Tar::Header.from @io
      return if header.empty?
      entry = GZippedTar::Tar::Entry.new header, @io

      yield entry

      skip_past_entry header.size, entry.bytes_read
      skip_past_trailing header.size

      # make sure nobody can use #read, #getc or #rewind anymore
      entry.close
    end
  end

  alias each_entry each

  # NOTE: Do not call #rewind during #each
  def rewind
    if @init_pos.zero?
      raise GZippedTar::Tar::NonSeekableIO unless @io.respond_to? :rewind
      @io.rewind
    else
      raise GZippedTar::Tar::NonSeekableIO unless @io.respond_to? :pos=
      @io.pos = @init_pos
    end
  end

  # Seeks through the tar file until it finds the +entry+ with +name+ and
  # yields it.  Rewinds the tar file to the beginning when the block
  # terminates.
  def seek(name)
    found = find do |entry|
      entry.full_name == name
    end

    return unless found

    return yield found
  ensure
    rewind
  end

  private

  attr_reader :io

  def skip_past_entry(size, read)
    # skip over the rest of the entry
    pending = size - read

    skip_by_seek
  rescue Errno::EINVAL, NameError
    skip_by_read pending
  end

  def skip_by_read(pending)
    while pending > 0
      bytes_read = io.read([pending, 4096].min).size
      pending -= bytes_read
      raise GZippedTar::Tar::UnexpectedEOF if io.eof? && !pending.zero?
    end
  end

  def skip_by_seek
    # avoid reading...
    io.seek pending, IO::SEEK_CUR
  end

  def skip_past_trailing(size)
    # discard trailing zeros
    skip = (512 - (size % 512)) % 512

    skip_by_read skip
  end
end
