# frozen_string_literal: true

class GZippedTar::Tar::WriteSignedFile
  def self.call(writer, name, mode, signer, &block)
    new(writer, name, mode, signer).call(&block)
  end

  def initialize(writer, name, mode, signer)
    @writer = writer
    @name   = name
    @mode   = mode
    @signer = signer
  end

  def call(&block)
    add_file_digest(&block)

    raise "no #{signer.digest_name} in #{digests.values.compact}" unless digest

    write_signature if signer.key

    digests
  end

  private

  attr_reader :writer, :name, :mode, :signer

  def add_file_digest(&block)
    writer.add_file name, mode do |io|
      GZippedTar::Tar::DigestIO.wrap io, digests, &block
    end
  end

  def algorithms
    [
      signer.digest_algorithm,
      Digest::SHA512
    ].compact.uniq
  end

  def digest
    @digest ||= digests.values.compact.detect do |digest|
      digest_name(digest) == signer.digest_name
    end
  end

  def digests
    @digests ||= begin
      digests = algorithms.collect(&:new).collect do |digest|
        [digest_name(digest), digest]
      end

      Hash[*digests.flatten]
    end
  end

  def digest_name(instance)
    if instance.respond_to? :name
      instance.name
    else
      instance.class.name[/::([^:]+)$/, 1]
    end
  end

  def write_signature
    signature = signer.sign digest.digest

    writer.add_file_simple "#{name}.sig", 0o444, signature.length do |io|
      io.write signature
    end
  end
end
