# frozen_string_literal: true

require "gzipped_tar/writer"

RSpec.describe GZippedTar::Writer do
  let(:subject)      { GZippedTar::Writer.new }
  let(:archive_path) { "archive.tar.gz" }

  describe "#add" do
    it "adds the path and contents to the archive" do
      subject.add "file.txt", "hello world"

      File.write archive_path, subject.output
      `tar -xzf #{archive_path}`

      expect(File.read("file.txt")).to eq("hello world")
    end
  end
end
