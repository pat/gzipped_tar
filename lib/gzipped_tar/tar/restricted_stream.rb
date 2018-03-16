# frozen_string_literal: true

#--
# Original source is copyright (C) 2004 Mauricio Julio Fernández Pradier
# This file has been copied and adapted to avoid reliance on differing
# behaviour across versions of rubygems, and to handle nil header values at
# the end of a file.
#++

# IO wrapper that provides only #write
class GZippedTar::Tar::RestrictedStream
  # Creates a new RestrictedStream wrapping +io+
  def initialize(io)
    @io = io
  end

  # Writes +data+ onto the IO
  def write(data)
    @io.write data
  end
end
