class Stemmer

  @vowels = /[аеиоуыэюя]/i
  @consonants = /[^аеиоуыэюя]/i
  # regexp for rv & r1 groups
  @rv_regexp = @vowels
  @r1_regexp = /#{@vowels}#{@consonants}/i
  # regexp for endings
  @perfective_gerund = /(([ая](в|вши|вшись))|(ив|ивши|ившись|ыв|ывши|ывшись))$/i
  @adjective = /(ее|ие|ые|ое|ими|ыми|ей|ий|ый|ой|ем|им|ым|ом|его|ого|ему|ому|их|ых|ую|юю|ая|яя|ою|ею)$/i
  @participle = /(([ая](ем|нн|вш|ющ|щ))|(ивш|ывш|ующ))$/i
  @reflexive = /(ся|сь)$/i
  @verb = /(([ая](ла|на|ете|йте|ли|й|л|ем|н|ло|но|ет|ют|ны|ть|ешь|нно))|(ила|ыла|ена|ейте|уйте|ите|или|ыли|ей|уй|ил|ыл|им|ым|ен|ило|ыло|ено|ят|ует|уют|ит|ыт|ены|ить|ыть|ишь|ую|ю))$/i
  @noun = /(а|ев|ов|ие|ье|е|иями|ями|ами|еи|ии|и|ией|ей|ой|ий|й|иям|ям|ием|ем|ам|ом|о|у|ах|иях|ях|ы|ь|ию|ью|ю|ия|ья|я)$/i
  @superlative = /(ейш|ейше)$/i
  @derivational = /(ост|ость)$/i
  @adjectival = /(#{@adjective})|(#{@participle}#{@adjective})$/i

  # $~['ignored'] ! 
  # puts "бегавшая" =~ (Regexp.new ([@participle, @adjective].map { |r| r.source.gsub('$', '') }.join))
  # @participle = /(((?<ignored>[ая])(ем|нн|вш|ющ|щ))|(ивш|ывш|ующ))$/i
  def init; end

  private

  def splice_by_pattern(regexp, word)
    index = word =~ regexp
    return unless index
    [word[0..index], word[index + 1..-1]]
  end

  def get_rv_area(word)
    return unless word
    spliced_word = splice_by_pattern @vowels, word
    return unless spliced_word
    spliced_word[1]
  end

  def get_r1_area(word)
    return unless word
    r1_area = word.split word.match(@r1_regexp).to_s
    return unless r1_area
    r1_area[1]
  end

  def get_r2_area(word)
    get_r1_area(get_r1_area(word))
  end

end