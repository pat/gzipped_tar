# frozen_string_literal: true

require "gzipped_tar"

RSpec.describe GZippedTar do
  it "can read and write gzipped tar data" do
    writer = GZippedTar::Writer.new
    writer.add "test.ext", "melbourne"

    reader = GZippedTar::Reader.new writer.output
    expect(reader.read("test.ext")).to eq("melbourne")
  end
end
