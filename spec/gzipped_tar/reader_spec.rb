# frozen_string_literal: true

require "gzipped_tar/reader"

RSpec.describe GZippedTar::Reader do
  let(:subject)      { GZippedTar::Reader.new File.read(archive_path) }
  let(:archive_path) { "archive.tar.gz" }

  before :example do
    File.write "file.txt", "hello world"

    `tar -czf #{archive_path} file.txt`
  end

  describe "#read" do
    it "returns the contents of the file at the given path" do
      expect(subject.read("file.txt")).to eq("hello world")
    end

    it "returns nil if the path is not valid" do
      expect(subject.read("missing.ext")).to be_nil
    end

    it "can find files more than once" do
      expect(subject.read("file.txt")).to eq("hello world")
      expect(subject.read("file.txt")).to eq("hello world")
    end
  end
end
