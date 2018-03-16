# frozen_string_literal: true

#++
# Original source is copyright (C) 2004 Mauricio Julio Fernández Pradier
# This file has been copied and adapted to avoid reliance on differing
# behaviour across versions of rubygems, and to handle nil header values at
# the end of a file.
#--

##
#--
# struct tarfile_entry_posix {
#   char name[100];     # ASCII + (Z unless filled)
#   char mode[8];       # 0 padded, octal, null
#   char uid[8];        # ditto
#   char gid[8];        # ditto
#   char size[12];      # 0 padded, octal, null
#   char mtime[12];     # 0 padded, octal, null
#   char checksum[8];   # 0 padded, octal, null, space
#   char typeflag[1];   # file: "0"  dir: "5"
#   char linkname[100]; # ASCII + (Z unless filled)
#   char magic[6];      # "ustar\0"
#   char version[2];    # "00"
#   char uname[32];     # ASCIIZ
#   char gname[32];     # ASCIIZ
#   char devmajor[8];   # 0 padded, octal, null
#   char devminor[8];   # o padded, octal, null
#   char prefix[155];   # ASCII + (Z unless filled)
# };
#++
# A header for a tar file

class GZippedTar::Tar::Header
  Field         = GZippedTar::Tar::Field
  ChecksumField = GZippedTar::Tar::ChecksumField

  # rubocop:disable Layout/ExtraSpacing
  FIELDS = [
    Field.new(:name,     100, :required => true),
    Field.new(:mode,      8, :required => true, :octal => true),
    Field.new(:uid,       8, :default => 0, :octal => true),
    Field.new(:gid,       8, :default => 0, :octal => true),
    Field.new(:size,     12, :required => true, :octal => true),
    Field.new(:mtime,    12, :default => 0, :octal => true),
    # Custom behaviour for the checksum:
    ChecksumField.new(:checksum, 8, :octal => true),
    # And back to normal:
    Field.new(:typeflag,   1, :default => "0"),
    Field.new(:linkname, 100),
    Field.new(:magic,      6, :default => "ustar"),
    Field.new(:version,    2, :default => "00", :octal => true),
    Field.new(:uname,     32, :default => "wheel"),
    Field.new(:gname,     32, :default => "wheel"),
    Field.new(:devmajor,   8, :default => 0, :octal => true),
    Field.new(:devminor,   8, :default => 0, :octal => true),
    Field.new(:prefix,   155, :required => true)
  ].freeze
  # rubocop:enable Layout/ExtraSpacing

  PACK_FORMAT    = FIELDS.collect(&:pack).join("")
  UNPACK_FORMAT  = FIELDS.collect(&:unpack).join("")
  HEADER_LENGTH  = 512
  BLANK          = {
    :name   => "",
    :size   => "0",
    :prefix => "",
    :mode   => "644",
    :empty  => true
  }.freeze

  # Creates a tar header from IO +stream+
  def self.from(stream)
    header = stream.read HEADER_LENGTH
    return new(BLANK) if header.nil?

    empty = (header == "\0" * HEADER_LENGTH)

    new values_from_array(header.unpack(UNPACK_FORMAT)).merge(:empty => empty)
  end

  def self.values_from_array(values)
    hash = {}

    FIELDS.each_with_index do |field, index|
      hash[field.name] = field.translate values[index]
    end

    hash
  end

  def initialize(values)
    validate values

    @empty  = values.delete :empty
    @values = FIELDS.inject({}) do |hash, field|
      hash[field.name] = field.translate values[field.name]
      hash
    end

    @values[:typeflag] = "0" if @values[:typeflag].empty?
  end

  def ==(other) # :nodoc:
    other.is_a?(self.class) &&
      FIELDS.all? { |field| values[field.name] == other.values[field.name] }
  end

  def empty?
    @empty
  end

  def name
    @values[:name]
  end

  def prefix
    @values[:prefix]
  end

  def size
    values[:size]
  end

  def to_s # :nodoc:
    update_checksum
    build_header
  end

  protected

  attr_reader :values

  private

  def calculate_checksum(header)
    header.unpack("C*").inject { |a, b| a + b }
  end

  def build_header
    header = header_values.pack PACK_FORMAT

    header + ("\0" * ((HEADER_LENGTH - header.size) % HEADER_LENGTH))
  end

  def header_values
    FIELDS.collect { |field| field.to_s values[field.name] }.flatten
  end

  def update_checksum
    values[:checksum] = nil
    values[:checksum] = calculate_checksum(build_header)
  end

  def validate(values)
    FIELDS.select(&:required?).each do |field|
      next if values[field.name]

      raise ArgumentError, ":name, :size, :prefix and :mode required"
    end
  end
end
