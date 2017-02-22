require 'fileutils'

module Mores::Patch::FileUtils

  refine ::FileUtils.singleton_class do
    def compare_stream(a, b)
      bsize = stream_blksize(a, b)
      sa = 0.chr(Encoding::BINARY) * bsize
      sb = 0.chr(Encoding::BINARY) * bsize
      begin
        a.read(bsize, sa)
        b.read(bsize, sb)
        return true if sa.empty? && sb.empty?
      end while sa == sb
      false
    end

    def safe_write(path, string)
      File.write path, string, mode: File::CREAT | File::EXCL | File::WRONLY
    rescue Errno::EEXIST
      ext ||= File.extname path
      base ||= File.basename(path, ext) << '_0'
      dir ||= File.dirname(path)

      path = File.join dir, base.next! + ext
      retry
    end

    private

    def stream_blksize(*streams)
      streams.each do |s|
        s.respond_to?(:stat) and
        blksize = s.stat.blksize and
        0 != blksize and
        return blksize
      end
      0x400
    end
  end

end
