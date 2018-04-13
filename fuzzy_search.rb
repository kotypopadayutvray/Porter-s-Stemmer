class FuzzySearch
  attr_accessor :n_gram_length, :levenshtein_chosen_distance

  def initialize(n_gram_length, levenshtein_chosen_distance)
    @n_gram_length = n_gram_length
    @levenshtein_chosen_distance = levenshtein_chosen_distance
  end

  def n_gramms(word, length)
    (0..word.length - length).map { |i| word[i, length] }
  end

  def levenshtein_distance(word1, word2)
    m = word1.length
    n = word2.length
    distance = []
    (m + 1).times { distance << [0] * (n + 1) }
    distance[0] = distance.first.each_with_index.map { |_, i| i }
    distance.each_with_index { |e, i| e[0] = i }
    (1..(distance.length - 1)).each do |i|
      (1..(distance[i].length - 1)).each do |j|
        distance[i][j] = if word1[i - 1] == word2[j - 1]
                           distance[i - 1][j - 1]
                         else
                           [distance[i - 1][j - 1], distance[i][j - 1], distance[i - 1][j]] + 1
                         end
      end
    end
    distance.last.last
  end

  def search(dictionary, word)
    n_gramms = n_gramms(word, @n_gram_length)
    same = n_gramms.map do |trigramm|
      regexp = Regexp.new(trigramm, 'i')
      dictionary.select { |dict_word| dict_word =~ regexp }
    end.flatten
    same.select { |e| levenshtein(e, word) <= @levenshtein_chosen_distance }.flatten.uniq
  end
end