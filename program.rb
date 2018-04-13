require './stemmer.rb'
require './fuzzy_search.rb'

def initialize_stemmer_dictionary(file_path)
  dictionary = {}
  File.open(file_path, 'r') do |file|
    while (line = file.gets)
      word, word_base = line.encode('UTF-8').chomp.split
      dictionary[word_base] << word if dictionary[word_base]
      dictionary[word_base] = [word] unless dictionary[word_base]
    end
  end
  dictionary
end

def initialize_dictionary(file_path)
  dictionary = []
  File.open(file_path, 'r') do |file|
    while (line = file.gets)
      word, = line.encode('UTF-8').chomp.split
      dictionary << word
    end
  end
  dictionary
end

abort 'No command line arguments' if ARGV.length.zero?

puts 'Initialazing dictionary for stemming. Wait please...'
stemmer_dictionary = initialize_stemmer_dictionary(ARGV[0])
puts 'Initialazing dictionary. Wait please...'
dictionary = initialize_dictionary(ARGV[0])
puts 'Dictionary initialazed!'

stemmer = Stemmer.new
fuzzy_search = FuzzySearch.new(3, 2)

loop do
  puts 'Enter 0 to exit from program'
  puts 'Enter 1 to find words with the same base part'
  puts 'Enter 2 to find all possible word\'s corrections'
  print 'Your answer: '
  answer = $stdin.gets.chomp.to_i
  case answer
  when 0
    break
  when 1
    word = $stdin.gets.chomp.downcase.gsub('ё', 'е')
    same_words = stemmer_dictionary[stemmer.stem(word)].join(',')
    puts "All words with the same base: #{same_words}\n\n"
  when 2
    word = $stdin.gets.chomp.downcase.gsub('ё', 'е')
    puts fuzzy_search.search(Dictionary, word)
  else
    puts "Wrong answer. Try again.\n\n"
  end
end
