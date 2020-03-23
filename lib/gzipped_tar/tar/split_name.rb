# frozen_string_literal: true

class GZippedTar::Tar::SplitName
  MAXIMUM_LENGTH      = 256
  MAXIMUM_NAME_LENGTH = 100
  MAXIMUM_PATH_LENGTH = 155

  def self.call(file)
    new(file).call
  end

  def initialize(file)
    @file = file
  end

  def call
    return ["", file] unless split?

    raise_if_too_long file,   MAXIMUM_LENGTH,      "path"
    raise_if_too_long name,   MAXIMUM_NAME_LENGTH, "name"
    raise_if_too_long prefix, MAXIMUM_PATH_LENGTH, "base path"

    [prefix, name]
  end

  private

  attr_reader :file

  def last_prefix_index
    @last_prefix_index ||= begin
      index = parts.length - 2
      index -= 1 while parts[0..index].join("/").bytesize >= MAXIMUM_PATH_LENGTH
      index
    end
  end

  def name
    parts[(last_prefix_index + 1)..-1].join("/")
  end

  def parts
    @parts ||= file.split "/", -1
  end

  def prefix
    parts[0..last_prefix_index].join("/")
  end

  def raise_if_too_long(string, maximum, description)
    return if string.bytesize <= maximum

    raise GZippedTar::Tar::TooLongFileName,
          "File \"#{string}\" has a too long #{description} (should be " \
          "#{maximum} or less)"
  end

  # If the file is less than MAXIMUM_NAME_LENGTH, it doesn't need to be split,
  # and the prefix can be blank.
  def split?
    file.bytesize > MAXIMUM_NAME_LENGTH
  end

  def too_long?
    file.bytesize > 256
  end
end
