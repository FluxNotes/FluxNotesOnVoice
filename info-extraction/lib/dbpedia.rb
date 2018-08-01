require 'net/http'
require 'uri'
require 'json'

PATTERN = /http:\/\/dbpedia.org\/resource\/(.*)/

class DBPedia
    @@cache = {}

    def self.loadDBPediaDataType(dbPediaURL)
        return @@cache[dbPediaURL] if @@cache[dbPediaURL]
        object = PATTERN.match(dbPediaURL)[1]
        uri = URI.parse("http://dbpedia.org/data/#{object}.json")
        response = Net::HTTP.get(uri)
        jsonResponse = JSON.parse(response)
        @@cache[dbPediaURL] = jsonResponse["http://dbpedia.org/resource/#{object}"]["http://www.w3.org/1999/02/22-rdf-syntax-ns#type"]
        jsonResponse["http://dbpedia.org/resource/#{object}"]["http://www.w3.org/1999/02/22-rdf-syntax-ns#type"]
    end    
end
