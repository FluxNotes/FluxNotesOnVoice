#!ruby

require "trollop"

require_relative "watson4fluxnotes.rb"
opts = Trollop::options do
  opt :text, "single string to analyze", :type => :string        # string --text <s>, default nil
  opt :file, "file containing line-by-line strings to be analyzed", :type => :io
  opt :output, "destination for analyzed data (default STDOUT)", :type => :string
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

watson = Watson4Fluxnotes.new

texts.each do |text|
  out.puts watson.analyze_text text
end


