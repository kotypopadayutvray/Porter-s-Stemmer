require './stemmer.rb'

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

def levenshtein(word1, word2)
  m, n = word1.length, word2.length
  distance = []
  (m + 1).times { distance << [0] * (n + 1) }
  distance[0] = distance.first.each_with_index.map { |_, i| i }
  distance.each_with_index { |e, i| e[0] = i }
  (1..(distance.length - 1)).each do |i|
    (1..(distance[i].length - 1)).each do |j|
      distance[i][j] = if word1[i - 1] == word2[j - 1]
                         distance[i - 1][j - 1]
                       else
                         a = [distance[i - 1][j - 1], distance[i][j - 1], distance[i - 1][j]]
                         a.min + 1
                       end
    end
  end
  distance.last.last
end

def n_gramm(word, length)
  (0..word.length - length).map { |i| word[i, length] }
end

def find_same_words(dictionary, word)
  trigramms = n_gramm(word, 3)
  same = trigramms.map do |trigramm|
    regexp = Regexp.new(trigramm, 'i')
    dictionary.select { |dict_word| dict_word =~ regexp }
  end.flatten
  same.select { |e| levenshtein(e, word) <= 2 }
end

abort 'No command line arguments' if ARGV.length.zero?

puts 'Initialazing dictionary for stemming. Wait please...'
stemmer_dictionary = initialize_stemmer_dictionary(ARGV[0])
puts 'Initialazing dictionary. Wait please...'
dictionary = initialize_stemmer_dictionary(ARGV[0])
puts 'Dictionary initialazed!'

stemmer = Stemmer.new

loop do
  puts 'Enter 1 to find words with the same base part'
  puts 'Enter 2 to find all possible word\'s corrections'
  print 'Your answer: '
  answer = $stdin.gets.chomp.to_i
  case answer
  when 0
    break
  when 1
    word = $stdin.gets.chomp
    same_words = stemmer_dictionary[stemmer.stem(word)].join(',')
    puts "All words with the same base: #{same_words}\n\n"
  when 2
    word = $stdin.gets.chomp
    puts find_same_words(dictionary, word)
  else
    puts "Wrong answer\n\n"
  end
end
