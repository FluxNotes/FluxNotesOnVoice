

#document = "and well the I'm sorry to hear that you're having this that you're experiencing this is myalgias in this this this neuropathy chances are on this is a side effect for a toxicity associated with the the the taxol and a tweet we do see this every now and then to be going to last forever if we decide to stop the medication but that's a decision that you know that we can we can talk more about the good news today is that I reviewed your your CT scan from last week and I'm in your disease status appears to be stable based on the results of that that CT Imaging from last week getting any better you're not getting any worse"


class Chunker
  attr_accessor :chunks, :context_length_left, :context_length_right
  def initialize (target, context_length)
    @target = target # what kinds of chunks are we looking for? :toxicity, :disease_status
    @context_length_left = @context_length_right = context_length # number of characters to each side of keyword we should include in the chunk
    @chunks = []
  end
  
  def run(document)
    toxicity_keywords = case @target
                        when :toxicity
                          [
                            /toxicit(y|ies)/i, #also use global? /g?
                            /side effects?/i
                          ]
                        when :disease_status
                          [
                            /status/i,
                            /progressing/i,
                            /stable/i,
                            /getting worse/i,
                            /worsening/i,
                            /improving/i,
                            /getting better/i
                          ]
                        else
                          raise "Unknown chunking target: #{target}"
                        end
    
    matches = []
    toxicity_keywords.each do |key| # each keyword is actually a regex pattern
      # consider converting to AnnotatedString and creating a Standoff tag if we want to do more with the keyword position later
      matches += document.to_enum(:scan, key).map { Regexp.last_match } # this would be just key.match document, but we want MatchData for possible multiple keyword matches, not just one
    end
    
    # for now, naive chunker just grabs a window of a constant character width centered around each key found
    # this will almost certainly need to get smarter (by using token, sentence, and speaker boundaries, and/or trained models or syntax)
    chunk_windows_by_start_and_end_positions = matches.map do |m|
      chunk_start = [0, m.begin(0) - @context_length_left].max # expand chunk to the left from the key. make sure we have a non-negative start position so it doesn't wrap around to the end
      chunk_end = [document.length, m.end(0) + @context_length_right].min # ditto to the right
      [chunk_start, chunk_end]
    end
    
    # merge overlapping chunks; the merging iterator relies on the order provided by .sort!
    chunk_windows_by_start_and_end_positions.sort!
    chunk_windows_by_start_and_end_positions.each_with_index do |positions, i|
      chunk_start, chunk_end = positions
      while i+1 < chunk_windows_by_start_and_end_positions.length && chunk_windows_by_start_and_end_positions[i+1].first < chunk_end
        chunk_end = chunk_windows_by_start_and_end_positions[i+1].last
        chunk_windows_by_start_and_end_positions.delete_at i+1
      end
      
      chunk_length = chunk_end - chunk_start + 1
      @chunks << document.slice(chunk_start, chunk_length)
    end
    @chunks.compact!
  end
end



#c = Chunker.new
#c.run document
#puts c.chunks.inspect
