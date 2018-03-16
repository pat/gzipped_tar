# frozen_string_literal: true

#--
# Original source is copyright (C) 2004 Mauricio Julio Fernández Pradier
# This file has been copied and adapted to avoid reliance on differing
# behaviour across versions of rubygems, and to handle nil header values at
# the end of a file.
#++

class GZippedTar::Tar::Writer
  ROW_WIDTH = GZippedTar::Tar::ROW_WIDTH

  def self.new(io)
    writer = super

    return writer unless block_given?

    begin
      yield writer
    ensure
      writer.close
    end

    nil
  end

  # Creates a new TarWriter that will write to +io+
  def initialize(io)
    raise GZippedTar::Tar::NonSeekableIO unless io.respond_to? :pos=

    @io     = io
    @closed = false
  end

  # Adds file +name+ with permissions +mode+, and yields an IO for writing the
  # file to.
  def add_file(name, mode, &block)
    check_closed

    GZippedTar::Tar::WriteFile.call self, io, name, mode, &block

    self
  end

  # Adds +name+ with permissions +mode+ to the tar, yielding +io+ for writing
  # the file.  The +signer+ is used to add a digest file using its
  # digest_algorithm per add_file_digest and a cryptographic signature in
  # +name+.sig.  If the signer has no key only the checksum file is added.
  #
  # Returns the digest.
  def add_file_signed(name, mode, signer, &block)
    GZippedTar::Tar::WriteSignedFile.call self, name, mode, signer, &block
  end

  # Add file +name+ with permissions +mode+ +size+ bytes long.  Yields an IO
  # to write the file to.
  def add_file_simple(name, mode, size)
    write_header name, mode, :size => size

    stream = GZippedTar::Tar::BoundedStream.new io, size

    yield stream if block_given?

    min_padding = size - stream.written
    io.write("\0" * min_padding)

    pad_rows size

    self
  end

  # Adds symlink +name+ with permissions +mode+, linking to +target+.
  def add_symlink(name, target, mode)
    write_header name, mode, :typeflag => "2", :linkname => target
  end

  # Closes the TarWriter
  def close
    check_closed

    io.write GZippedTar::Tar::EMPTY_ROW
    io.write GZippedTar::Tar::EMPTY_ROW
    flush

    @closed = true
  end

  # Is the TarWriter closed?
  def closed?
    @closed
  end

  # Flushes the TarWriter's IO
  def flush
    check_closed

    io.flush if io.respond_to? :flush
  end

  # Creates a new directory in the tar file +name+ with +mode+
  def mkdir(name, mode)
    write_header name, mode, :typeflag => "5"
  end

  def pad_rows(size)
    remainder = (ROW_WIDTH - (size % ROW_WIDTH)) % ROW_WIDTH

    io.write "\0" * remainder
  end

  def write_header(name, mode, options = {})
    check_closed

    prefix, name = GZippedTar::Tar::SplitName.call name

    io.write GZippedTar::Tar::Header.new({
      :name   => name,
      :mode   => mode,
      :prefix => prefix,
      :size   => 0,
      :mtime  => Time.now
    }.merge(options))

    self
  end

  private

  attr_reader :io

  # Raises IOError if the TarWriter is closed
  def check_closed
    raise IOError, "closed #{self.class}" if closed?
  end
end
