# GZipped Tar

A simple interface for reading and writing gzipped tar files (.tar.gz) in memory, without needing for any files to be stored in the file system.

## Installation

```ruby
gem "gzipped_tar", "~> 0.1.2"
```

## Usage

This library lets you work with gzipped tar files directly. If you're reading, you don't need to extract all the files into the file system, and if you're writing, you can add content in without needing it to be persisted to the file system either.

```ruby
# Add a path and its content to a gzipped tar archive
writer = GZippedTar::Writer.new
writer.add "file.txt", "hello world"

# Write that archive to disk:
File.write "archive.tar.gz", writer.output

# Read in an existing archive:
reader = GZippedTar::Reader.new File.read("archive.tar.gz")
# Or straight from a writer:
reader = GZippedTar::Reader.new writer.output

# And then get the contents of a path in that file:
reader.read "file.txt" #=> "hello world"
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pat/gzipped_tar. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the GZipped Tar project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/pat/gzipped_tar/blob/master/CODE_OF_CONDUCT.md).
