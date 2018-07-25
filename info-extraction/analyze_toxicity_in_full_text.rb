#!ruby

require "trollop"

require_relative "lib/watson4fluxnotes.rb"
require_relative "lib/meddra4fluxnotes.rb"
require_relative "lib/chunker.rb"
require_relative "lib/findings_collector.rb"

opts = Trollop::options do
  opt :text, "single string to analyze", :type => :string        # string --text <s>, default nil
  opt :file, "file containing line-by-line strings to be analyzed", :type => :io
  opt :output, "destination for analyzed data (default STDOUT)", :type => :string
  opt :outputFormat, "output format; values: json, spreadsheet", :type => :string, :default => "json"
  opt :meddra_score_threshold, "only keep disease mentions that score higher than this", :type => :float, :default => 6.5
end

if opts[:text] && opts[:file]
  raise "usage error: please use either --text (-t) or --file (-f), not both"
end

if opts[:text]
  texts = [opts[:text]]
elsif opts[:file]
  #TODO
  texts = opts[:file].readlines
end

if opts[:output]
  out = File.open(opts[:output], 'w') 
else
  out = STDOUT
end


chunker = Chunker.new
watson = Watson4Fluxnotes.new
meddra = Meddra4Fluxnotes.new
collector = FindingsCollector.new


texts.each do |text|
  puts "ANALYZING TEXT"
  results = []
  chunker.run text, :toxicity # find the chunks of text related to toxicity
  
  # analyze the chunks via Watson, and filter the results down to relevant findings:

  chunker.chunks.map do |chunk|
    puts "sending to Watson: #{chunk}"
    watson.analyze_text(chunk)
    
  end.each do |result| # each result is the Watson output for the given chunk (after various filtering)
    # collect what we need from the extracted features
    result["entities"].each do |e|
      collector << {:text => e["text"],
                    :analytic_source => "Watson",
                    :feature => "Entity",
                    :type => e["type"],
                    :score => e["relevance"],
                    :context => result["analyzed_text"]}
    end
    result["concepts"].each do |c|
      collector << {:text => c["text"],
                    :analytic_source => "Watson",
                    :feature => "Concept",
                    :code => c["dbpedia_resource"].sub("http://dbpedia.org/resource/", ""),
                    :score => c["relevance"],
                    :context => result["analyzed_text"]}
    end
  end
  
  
  # analyze the chunks via MedDRA, and filter results down to high-scoring findings:
  chunker.chunks.each do |chunk|
    puts "sending to MedDRA: #{chunk}"
    concepts = meddra.analyze_text(chunk, opts[:meddra_score_threshold])
    
    concepts.each do |c|
      collector << {:text => c["term"], :analytic_source => "MedDRA", :code => c["code"], :score => c["score"], :context => chunk}
    end
    
  end
  
  # write what we've found
  collector.puts out, opts[:outputFormat]
  
end

