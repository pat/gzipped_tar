# frozen_string_literal: true

class GZippedTar::Tar::ChecksumField < GZippedTar::Tar::Field
  EMPTY_VALUE = [" " * 8, " "].freeze

  def pack
    "a7a"
  end

  def unpack
    "A8"
  end

  def to_s(value)
    return EMPTY_VALUE if value.nil?

    [format("%06o", value), " "]
  end
end
