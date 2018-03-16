# frozen_string_literal: true

class GZippedTar::Tar::Field
  attr_reader :name, :length, :octal, :required, :default

  def initialize(name, length, options = {})
    @name     = name
    @length   = length
    @octal    = options[:octal]
    @required = options[:required]
    @default  = options[:default]
  end

  def octal?
    octal
  end

  def pack
    return "a" if length == 1

    "a#{length}"
  end

  def required?
    required
  end

  def to_s(value)
    return value unless octal?

    if length == 2
      format "%0#{length}o", value
    else
      format "%0#{length - 1}o", value
    end
  end

  def translate(value)
    value ||= default

    return value unless octal? && value.is_a?(String)
    return value.oct if value[/\A[0-7]*\z/]

    raise ArgumentError, "#{value.inspect} is not an octal string"
  end

  def unpack
    return "A" if length == 1

    "A#{length}"
  end
end
