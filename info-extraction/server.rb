require 'sinatra'
require 'json'
# require 'byebug'

require_relative "lib/watson4fluxnotes.rb"
require_relative "lib/meddra4fluxnotes.rb"
require_relative "lib/chunker.rb"
require_relative "lib/findings_collector.rb"

get '/' do 
    'Post text to the /watson end point as a "text" param to run watson NLP'
end

post '/watson' do 
    # Chunk data into multiple lines
    text = params['text']
    chunker = Chunker.new
    watson = Watson4Fluxnotes.new

    chunker.run text, :toxicity
    results = chunker.chunks.map do |chunk|
        watson.analyze_text(chunk)
    end
    content_type :json
    results.to_json
end