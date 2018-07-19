require 'net/http'
require 'json'


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
    res = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') {|http|
      http.request(req)
    }
    puts res.body
  end
  
  def construct_data (text, feature_list)
    feature_hash = {}
    feature_list.each{|f| feature_hash[f] = {}}
    data = {
      "text" => text,
      "features" => feature_hash
    }
    return data.to_json
  end
  
end

watson = Watson4Fluxnotes.new

watson.analyze_text "and well the I'm sorry to hear that you're having this that you're experiencing this is myalgias in this this this neuropathy chances are on this is a side effect for a toxicity associated with the the the taxol and a tweet we do see this every now and then"

