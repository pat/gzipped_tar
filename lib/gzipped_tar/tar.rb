# frozen_string_literal: true

module GZippedTar
  module Tar
    ROW_WIDTH = 512
    EMPTY_ROW = "\0" * ROW_WIDTH

    Error = Class.new StandardError

    FileOverflow    = Class.new Error
    NonSeekableIO   = Class.new Error
    TarInvalidError = Class.new Error
    TooLongFileName = Class.new Error
    UnexpectedEOF   = Class.new Error
  end
end

require "gzipped_tar/tar/bounded_stream"
require "gzipped_tar/tar/digest_io"
require "gzipped_tar/tar/entry"
require "gzipped_tar/tar/field"
require "gzipped_tar/tar/checksum_field"
require "gzipped_tar/tar/header"
require "gzipped_tar/tar/reader"
require "gzipped_tar/tar/restricted_stream"
require "gzipped_tar/tar/split_name"
require "gzipped_tar/tar/writer"
require "gzipped_tar/tar/write_file"
require "gzipped_tar/tar/write_signed_file"
