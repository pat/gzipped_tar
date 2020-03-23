# frozen_string_literal: true

#--
# Original source is copyright (C) 2004 Mauricio Julio Fernández Pradier
# This file has been copied and adapted to avoid reliance on differing
# behaviour across versions of rubygems, and to handle nil header values at
# the end of a file.
#++

class GZippedTar::Tar::BoundedStream
  # Maximum number of bytes that can be written
  attr_reader :limit

  # Number of bytes written
  attr_reader :written

  # Wraps +io+ and allows up to +limit+ bytes to be written
  def initialize(io, limit)
    @io = io
    @limit = limit
    @written = 0
  end

  # Writes +data+ onto the IO, raising a FileOverflow exception if the
  # number of bytes will be more than #limit
  def write(data)
    if data.bytesize + @written > @limit
      raise GZippedTar::Tar::FileOverflow,
            "You tried to feed more data than fits in the file."
    end
    @io.write data
    @written += data.bytesize
    data.bytesize
  end
end
