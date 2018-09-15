require 'sinatra'
require 'json'
# require 'byebug'

require_relative "lib/watson4fluxnotes.rb"
require_relative "lib/meddra4fluxnotes.rb"
require_relative "lib/chunker.rb"
require_relative "lib/findings_collector.rb"
require_relative "lib/disease_status_extractor.rb"


get '/' do 
    'Post text to the /watson end point as a "text" param to run watson NLP'
end

post '/watson' do 
    # Chunk data into multiple lines
    text = params['text']
    chunkSize = params['chunkSize'] || 110
    chunkerToxicity = Chunker.new :toxicity, chunkSize
    chunkerDiseaseStatus = Chunker.new :disease_status, chunkSize
    watson = Watson4Fluxnotes.new
    extractor = DiseaseStatusExtractor.new


    chunkerToxicity.run text
    chunkerDiseaseStatus.run text
    toxicityResults = chunkerToxicity.chunks.map do |chunk|
        watson.analyze_text(chunk)
    end
    diseaseResults = chunkerDiseaseStatus.chunks.map do |chunk|
        extractor.analyze_text(chunk)
    end
    content_type :json
    flux_notes_messages = []
    diseaseResults.each do |res|
        res.each do |concept|
          flux_notes_messages << "flux_command('insert-structured-phrase', {phrase:'disease status', fields: [{name:'status', value: #{concept.to_json}}]})"
        end
    end
    toxicityResults.each do |tox| 
        tox['concepts'].each do |concept| 
            flux_notes_messages << "flux_command('insert-structured-phrase', {phrase:'toxicity', fields: [{name:'adverseEvent', value: '#{concept['text']}'}]})"
        end
    end
    return {
        diseaseStatus: diseaseResults,
        toxicity: toxicityResults,
        fluxCommands: flux_notes_messages.uniq
    }.to_json
end
