# frozen_string_literal: true

#--
# Original source is from Rubygems.
# This file has been copied and adapted to avoid reliance on differing
# behaviour across versions of rubygems, and to handle nil header values at
# the end of a file.
#++

# IO wrapper that creates digests of contents written to the IO it wraps.
class GZippedTar::Tar::DigestIO
  # Collected digests for wrapped writes.
  #
  #   {
  #     'SHA1'   => #<OpenSSL::Digest: [...]>,
  #     'SHA512' => #<OpenSSL::Digest: [...]>,
  #   }
  attr_reader :digests

  # Wraps +io+ and updates digest for each of the digest algorithms in
  # the +digests+ Hash.  Returns the digests hash.  Example:
  #
  #   io = StringIO.new
  #   digests = {
  #     'SHA1'   => OpenSSL::Digest.new('SHA1'),
  #     'SHA512' => OpenSSL::Digest.new('SHA512'),
  #   }
  #
  #   GZippedTar::Tar::DigestIO.wrap io, digests do |digest_io|
  #     digest_io.write "hello"
  #   end
  #
  #   digests['SHA1'].hexdigest   #=> "aaf4c61d[...]"
  #   digests['SHA512'].hexdigest #=> "9b71d224[...]"
  def self.wrap(io, digests)
    digest_io = new io, digests

    yield digest_io

    digests
  end

  # Creates a new DigestIO instance.  Using ::wrap is recommended, see the
  # ::wrap documentation for documentation of +io+ and +digests+.
  def initialize(io, digests)
    @io = io
    @digests = digests
  end

  # Writes +data+ to the underlying IO and updates the digests
  def write(data)
    result = @io.write data

    @digests.each_value do |digest|
      digest << data
    end

    result
  end
end
