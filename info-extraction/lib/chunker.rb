

#document = "and well the I'm sorry to hear that you're having this that you're experiencing this is myalgias in this this this neuropathy chances are on this is a side effect for a toxicity associated with the the the taxol and a tweet we do see this every now and then to be going to last forever if we decide to stop the medication but that's a decision that you know that we can we can talk more about the good news today is that I reviewed your your CT scan from last week and I'm in your disease status appears to be stable based on the results of that that CT Imaging from last week getting any better you're not getting any worse"


class Chunker
  attr_accessor :chunks, :context_length_left, :context_length_right
  def initialize (context_length)
    @context_length_left = @context_length_right = context_length # number of characters to each side of keyword we should include in the chunk
  end
  
  def run(document, target)
    case target
    when :toxicity
      toxicity_keywords = [
        /toxicit(y|ies)/i, #also use global? /g?
        /side effects?/i
      ]
            
      toxicity_keywords.each do |key| # each keyword is actually a regex pattern
        # consider converting to AnnotatedString and creating a Standoff tag if we want to do more with the keyword position later
        matches = document.to_enum(:scan, key).map { Regexp.last_match } # this would be just key.match document, but we want MatchData for possible multiple keyword matches, not just one
        
        # for now, naive chunker just grabs a window of a constant character width centered around each key found
        # this will almost certainly need to get smarter (by using token, sentence, and speaker boundaries, and/or trained models or syntax)
        @chunks = matches.map do |m| # we'll probably want to merge overlapping chunks in this block later. if so, add sort_by{|m| m.begin(0)} before the map
          chunk_start = [0, m.begin(0) - @context_length_left].max # expand chunk to the left from the key. make sure we have a non-negative start position so it doesn't wrap around to the end
          chunk_end = [document.length, m.end(0) + @context_length_right].min # ditto to the right
          chunk_length = chunk_end - chunk_start + 1
          document.slice(chunk_start, chunk_length)
        end
        @chunks.compact! 
      end
    else
      raise "Unknown chunking target: #{target}"
    end
  end
end



#c = Chunker.new
#c.run document
#puts c.chunks.inspect
