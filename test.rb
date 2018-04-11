require 'test/unit'
require './stemmer.rb'

abort 'No command line arguments' if ARGV.length.zero?
# abort 'File does not exists!' if File.exist?(ARGV[0])
$file_path = ARGV[0]

# Test Porter's stemmer
class TestStemmer < Test::Unit::TestCase
  def test_simple
    stemmer = Stemmer.new
    file = File.open $file_path
    while (line = file.gets)
      l, r = line.encode('UTF-8').chomp.split
      assert_equal(r, stemmer.stem(l))
    end
    file.close
  end
end
