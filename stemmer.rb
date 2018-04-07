# Porter's stemming algorithm realized in this class
class Stemmer
  attr_accessor :vowels, :consonants, :rv_regexp, :r1_regexp,
                :perfective_gerund, :adjective, :participle,
                :reflexive, :verb, :noun, :superlative,
                :derivational

  def initialize
    @vowels = /[аеиоуыэюя]/i
    @consonants = /[^аеиоуыэюя]/i
    # regexp for rv & r1 groups
    @rv_regexp = @vowels
    @r1_regexp = /#{@vowels}#{@consonants}/i
    # regexp for endings
    @perfective_gerund = /(((?<preceded>[ая])(в|вши|вшись))|(ив|ивши|ившись|ыв|ывши|ывшись))$/i
    @adjective = /(ее|ие|ые|ое|ими|ыми|ей|ий|ый|ой|ем|им|ым|ом|его|ого|ему|ому|их|ых|ую|юю|ая|яя|ою|ею)$/i
    @participle = /(((?<preceded>[ая])(ем|нн|вш|ющ|щ))|(ивш|ывш|ующ))$/i
    @reflexive = /(ся|сь)$/i
    @verb = /(((?<preceded>[ая])(ла|на|ете|йте|ли|й|л|ем|н|ло|но|ет|ют|ны|ть|ешь|нно))|(ила|ыла|ена|ейте|уйте|ите|или|ыли|ей|уй|ил|ыл|им|ым|ен|ило|ыло|ено|ят|ует|уют|ит|ыт|ены|ить|ыть|ишь|ую|ю))$/i
    @noun = /(а|ев|ов|ие|ье|е|иями|ями|ами|еи|ии|и|ией|ей|ой|ий|й|иям|ям|ием|ем|ам|ом|о|у|ах|иях|ях|ы|ь|ию|ью|ю|ия|ья|я)$/i
    @superlative = /(ейш|ейше)$/i
    @derivational = /(ост|ость)$/i
  end

  def stem(word)
    return word if word.length == 1
    prefix = splice_by_pattern(@vowels, word)
    result = step_one word, get_rv_area(word)
    result = step_two result, get_rv_area(result)
    result = step_three result, get_r2_area(result)
    result = step_four result, get_rv_area(result)
    prefix && (result[0..(prefix[0].length - 1)] != prefix[0].to_s) ? prefix[0].to_s + result : result
  end

  private

  def splice_by_pattern(regexp, word)
    index = word =~ regexp
    return unless index
    [word[0..index], word[index + 1..-1]]
  end

  def get_rv_area(word)
    return unless word
    spliced_word = splice_by_pattern @vowels, word
    return '' unless spliced_word
    spliced_word[1]
  end

  def get_r1_area(word)
    return unless word
    matched = word.match(@r1_regexp).to_s
    r1_area = word.split matched
    return unless r1_area
    r1_area.delete_at(0)
    r1_area.join(matched)
  end

  def get_r2_area(word)
    get_r1_area(get_r1_area(word))
  end

  def step_one(word, rv_area)
    # Check for perfective gerund ending
    @perfective_gerund =~ rv_area
    matched = check_for_matches word, Regexp.last_match, @perfective_gerund
    return matched if matched
    # Check for reflexive ending
    result = word
    @reflexive =~ rv_area
    matched = check_for_matches word, Regexp.last_match, @reflexive
    result = matched if matched
    # Adjectival = adjective + participle
    @adjective =~ get_rv_area(result)
    if (matched = check_for_matches result, Regexp.last_match, @adjective)
      result = matched
      @participle =~ get_rv_area(matched)
      matched = check_for_matches result, Regexp.last_match, @participle
      return matched || result
    end
    # Check for other engings groups
    %i[verb noun].each do |r|
      regexp = send(r)
      regexp =~ get_rv_area(result)
      if (matched = check_for_matches result, Regexp.last_match, regexp)
        result = matched
        break
      end
    end
    result
  end

  def step_two(word, rv_area)
    return word[0..-2] if rv_area[-1] == 'и'
    word
  end

  def step_three(word, r2_area)
    @derivational =~ r2_area
    check_for_matches(word, Regexp.last_match, @derivational) || word
  end

  def step_four(word, rv_area)
    if rv_area.match?(/нн$/i) || rv_area.match?(/ь$/i)
      word[0..-2]
    elsif rv_area.match?(@superlative)
      result = word.gsub(@superlative, '')
      result.match?(/нн$/i) ? result[0..-2] : result
    else
      word
    end
  end

  def check_for_matches(word, match_data, regexp, group_name: :preceded)
    return unless match_data
    group_value = match_data&.names&.include?(group_name.to_s) ? match_data[group_name] : ''
    swap_regexp = Regexp.new(match_data.to_s + '$', regexp.options)
    word.gsub(swap_regexp, '') + group_value.to_s
  end
end
