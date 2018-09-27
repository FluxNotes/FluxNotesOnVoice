require 'sinatra'
require 'json'
require 'active_support/inflector'
require 'byebug'

require_relative "lib/watson4fluxnotes.rb"
require_relative "lib/meddra4fluxnotes.rb"
require_relative "lib/chunker.rb"
require_relative "lib/findings_collector.rb"
require_relative "lib/disease_status_extractor.rb"
require_relative "lib/fluxnotes_integration.rb"

FHIR_ROOT = 'https://syntheticmass.mitre.org'

get '/' do 
    'Post text to the /watson end point as a "text" param to run watson NLP'
end

post '/:patient_id/fn' do 
    featureTypes = {
        'allergy': "AllergyIntolerance?patient=#{params['patient_id']}",
        # 'medications': "MedicationDispense?patient=#{params['patient_id']}",
        'medication': "MedicationDispense?patient=#{params['patient_id']}",
        'condition': "Condition?patient=#{params['patient_id']}",
        # 'conditions': "Condition?patient=#{params['patient_id']}",
        'encounter': "Encounter?patient=#{params['patient_id']}",
        # 'encounters': "Encounter?patient=#{params['patient_id']}",
        'observation': "Observation?patient=#{params['patient_id']}",
        # 'observations': "Observation?patient=#{params['patient_id']}",
        'everything': "Patient/#{params['patient_id']}/$everything"
    }

    type_regex = featureTypes.map{|k,_| [k.to_s, k.to_s.pluralize]}.flatten

    text = params['text']
    # byebug
    features = text.match("show (#{type_regex.join("|")})")
    if features
        # byebug
        feature_type = featureTypes[features[1].singularize.to_sym]
        return "#{FHIR_ROOT}/fhir/#{feature_type}"
    end
    return {}.to_json

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
          # build the flux_command for each disease status assertion.
          # 'status' will have a single value, 'reasons' will have an array of values.
          # for each of those values, we use the normalized vocabulary term if we have it, or fall back to the surface mention text if we don't
          flux_notes_messages << FluxNotes.build_structured_phrase(
              'disease status',
              [
                  {name: 'status', value: concept[:status][:normalized] || concept[:status][:mention_text]},
                  {name: 'reason', value: concept[:rationale].map{|structured_rationale| structured_rationale[:normalized] || structured_rationale[:mention_text]}.join(", ")}
              ]
          )
    #   {name:'reasons', value: [#{concept[:rationale].map{|structured_rationale| '\'' + (structured_rationale[:normalized] || structured_rationale[:mention_text]) + '\''}.join(', ')}]
        #   "flux_command('insert-structured-phrase', {phrase:'disease status', fields: [{name:'status', value: '#{concept[:status][:normalized] || concept[:status][:mention_text]}'}, {name:'reasons', value: [#{concept[:rationale].map{|structured_rationale| '\'' + (structured_rationale[:normalized] || structured_rationale[:mention_text]) + '\''}.join(', ')}]}]})"
        end
    end
    
    toxicityResults.each do |tox| 
        tox['concepts'].each do |concept|
            #build the flux_command for each toxicity assertion.
            flux_notes_messages << FluxNotes.build_structured_phrase('toxicity', [{name: 'adverseEvent', value: concept['text']}])

        end
    end

    return {
        diseaseStatus: diseaseResults,
        toxicity: toxicityResults,
        fluxCommands: flux_notes_messages.uniq
    }.to_json
end
