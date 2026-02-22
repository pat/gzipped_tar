# frozen_string_literal: true

require "gzipped_tar/tar"

RSpec.describe GZippedTar::Tar::SplitName do
  it "allows blank prefixes when file is less than 100 characters" do
    expect(described_class.call("foo.txt")).to eq(["", "foo.txt"])
  end

  it "splits up files greater than 100 characters" do
    expect(
      described_class.call(
        "#{"123456789/" * 10}foo.txt"
      )
    ).to eq(
      ["#{"123456789/" * 9}123456789", "foo.txt"]
    )
  end

  it "balances path parts between name and prefix" do
    expect(
      described_class.call(
        "#{"123456789/" * 16}foo.txt"
      )
    ).to eq(
      ["#{"123456789/" * 14}123456789", "123456789/foo.txt"]
    )
  end

  it "raises an exception if the prefix is too long" do
    expect do
      described_class.call(
        "#{"1234567890" * 16}/foo.txt"
      )
    end.to raise_error(GZippedTar::Tar::TooLongFileName)
  end

  it "raises an exception if the name is too long" do
    expect do
      described_class.call(
        "#{"1234567890" * 10}foo.txt"
      )
    end.to raise_error(GZippedTar::Tar::TooLongFileName)
  end

  it "raises an exception if the file is too long" do
    expect do
      described_class.call(
        "#{"123456789/" * 26}foo.txt"
      )
    end.to raise_error(GZippedTar::Tar::TooLongFileName)
  end
end
