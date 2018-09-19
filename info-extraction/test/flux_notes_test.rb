require File.expand_path '../test_helper.rb', __FILE__
require 'json'
require 'execjs'
require 'byebug'

class HomePageTest < MiniTest::Unit::TestCase

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_front_page_responds
    get '/'
    assert last_response.ok?
    assert last_response.body.downcase.include? '/watson'
  end

  def test_flux_notes_command_generation
    post '/watson', params = {
      text: "All right
      Hello, my name is dr
      Houston
      I'm a medical oncologist
      I'm here with Debra a 45 year old woman who is a nurse assistant with metastatic recurrent breast cancer too
      Oh, right young month
      That's initially stage 1A infiltrating ductal
      Carcinoma Deborah
      How are you doing today? I'm not doing very well dear what's been going on? So it appears that I've had more numbness and tingling in my fingers my hands my feet
      Um, this is really affecting it a lot of what I need to do during the day guys
      This has this when did this start started shortly after my new treatment? Oh the tax and the receptive
      Yeah
      Okay
      So those those medications are part of the the new regiment that we started six weeks ago
      Right right
      Gotcha
      Um,Certainly notice
      These These toxicities are side effects the muscle that you're describing
      Um, the you mentioned tingling
      Yeah, so the peripheral sensory neuropathy
      Those are common side effects are toxicities that are associated with those two medications
      Um, it's something that certainly be concerned
      Mm
      I guess a follow-up question I would have is are these are is the numbness and tingling
      Is it affecting your normal day-to-day activities? Well this I'm having trouble going up and down the stairs
      I'm having trouble getting in and out of the shower even getting dressed
      Um, I'm just wondering how long this numbness tingling are going to um occur
      I mean, is this something that's that we think is going to happen for a couple of weeks or it's a great question
      So hopefully these side effects will not get worse and to hopefully subside because they're related
      to the medication, soumIs aren't um likely to be permanent that sense they should go away
      Um, but something that we should keep track of and ensure that they don't get worse so that if your activities are failing living are getting more, uh, pronounced affected, um, we should probably consider different treatment regimens
      Um and taking there's no medications
      How long are they going to stay in my system? I mean over time are they going to diminish diminish over time? Yeah, it should be something that um, you know, staying your support week or two, but then should be flushed out
      And is there something else I can do either another medication to try to um, reduce the symptom of feeling or um change my diet question
      So unfortunately, there's nothing really that can be done other than just resting and taking it easy
      Um if you have troubleIf you have worse trouble.Breathing anything like that
      You should contact our office immediately
      One of the things I wanted to make sure that we went over uh was the results from your CT scan
      So we had an enhanced, uh, CT scan done last week
      We're uh metastatic cancer and some of the results, um at a high level while one unit here that nothing's changed
      So it hasn't gotten worse and the fact that we just started the new treatment regimen six weeks ago
      You don't expect things to get better this quickly
      So they found the pulmonary nodules 4 to 5 millimeters in diameter along the right along side as well as some superficial, uh, uh post-surgical changes to the right breast in the axilla area, which would be uh, normal given that the mastectomy that that we had
      Um, so the nodules haven't gotten bigger
      Um, your disease is stable
      That's what we How we got?Getting bigger there are more of them
      Um, it's not progressing
      It is stable
      That's a very good thing
      So my recommendation is let's document the toxicities
      Let's make sure we understand that the and peripheral neuropathy I things to be concerned about in to watch and let's continue to track to make sure that those nodules start to diminish in size
      So in terms of patients, you see what's a percentage, um of patients that you see that maybe I'm somewhat identical to in that there's been no change what if percentages that maybe have gotten worse or even gotten better at this point
      I would say that every patient is their own unique story
      Um,
      "
    }
    source = "var flux_command = (a,b)=> { return 'command_executed'};"
    context = ExecJS.compile(source)
    assert last_response.ok?
    res = JSON.parse(last_response.body)
    res["fluxCommands"].each do |com| 
      assert com.instance_of? String
      assert_equal context.eval(com), 'command_executed'
    end
    assert res["fluxCommands"].length > 0
  end

  def test_404_page
    get '/asdfasdf'
    assert last_response.not_found?
  end

end