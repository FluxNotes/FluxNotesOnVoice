require 'net/http'


watson = Watson4Fluxnotes.new

watson.example_call

class Watson4Fluxnotes

  def example_call
    data = '{
      "text": "I still have a dream. It is a dream deeply rooted in the American dream. I have a dream that one day this nation will rise up and live out the true meaning of its creed: \"We hold these tru    ths to be self-evident, that all men are created equal.\"",
      "features": {
        "sentiment": {},
        "keywords": {}
      }
    }'
    
    url = URI.parse("https://gateway.watsonplatform.net/natural-language-understanding/api/v1/analyze?version=2018-03-19")
    req = Net::HTTP::Post.new(url.to_s, initheader = {'Content-Type' =>'application/json'})
    req.body = data
    req.basic_auth( "43ed518a-ca46-44f1-ba5f-442e636ce982", "Dhc0QsjieyTB")
    res = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') {|http|
      http.request(req)
    }
    puts res.body
  end

end
