require 'net/http'
require 'json'
require_relative "dbpedia.rb"

class Watson4Fluxnotes
  
  def example_call
    feature_list = ["sentiment", "keywords"]
    data = construct_data "I still have a dream. It is a dream deeply rooted in the American dream. I have a dream that one day this nation will rise up and live out the true meaning of its creed: \"We hold these truths to be self-evident, that all men are created equal.\"", feature_list
    
  end

  def analyze_text (text)
    feature_list = ["entities", "concepts"]
    data = construct_data text, feature_list
    api_call_analyze data
  end

  def api_call_analyze (data)
    # data is expected to be a json hash containing both the text to be analyzed and the desired features, as constructed by #construct_data()
    url = URI.parse("https://gateway.watsonplatform.net/natural-language-understanding/api/v1/analyze?version=2018-03-19")
    req = Net::HTTP::Post.new(url.to_s, initheader = {'Content-Type' =>'application/json'})
    req.body = data
    req.basic_auth( "43ed518a-ca46-44f1-ba5f-442e636ce982", "Dhc0QsjieyTB")
    results = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') {|http|
      http.request(req)
    }
    filter_to_desired_categories(JSON.parse(results.body))
  end

  def filter_to_desired_categories (results_hash)
    # we only care about entities of type "HealthCondition" (though that may be expanded later)
    results_hash["entities"].select!{|e| e["type"] == "HealthCondition"}
    # and concepts of type "Disease" (though that may be expanded later)
    #TODO: when we have real DBpedia type checking available, has_relevant_dbpedia_concept_type should be deleted and replaced
    results_hash["concepts"].select!{|c| has_relevant_dbpedia_concept_type c}
    results_hash
  end

  def has_relevant_dbpedia_concept_type ( concept )
    # concept should be a ruby hash generated from the json object returned in the watson concept list

    types_we_care_about = [
      "http://dbpedia.org/ontology/Disease",
      "http://umbel.org/umbel/rc/AilmentCondition"
    ]

    
    types = DBPedia.loadDBPediaDataType(concept['dbpedia_resource'])

    if types == nil 
      return false
    end
    # require 'byebug'
    #     byebug

    if (types.map{|t| t['value']} & types_we_care_about).length == 0
       return false
    end

    # this is a manually curated, example-specific list based on checking DBpedia pages. will be replaced with automated DBpedia queries.
    concepts_known_not_to_be_disease = [
      "Chemotherapy",
      "Pharmacology",
      "2006 albums",
      "2008 singles",
      "HIV",
      "Pain", # probably we want to catch this one. following the rules for now though.
      "Pharmaceutical drug",
      "Prescription drug"
    ]
    
    if concepts_known_not_to_be_disease.include? concept["text"]
      return false
    else
      return true
    end
  end

  def construct_data (text, feature_list)
    feature_hash = {} # we send the input data with a hash (with keys as features we want) of empty hashes (to be filled in with recognized feature instances by Watson)
    feature_list.each{|f| feature_hash[f] = {}}
    data = {
      "text" => text,
      "features" => feature_hash,
      "return_analyzed_text" => true
    }
    return data.to_json
  end
  
end


