require 'standoff'

#text = "Hi. Mrs. Ortiz. Great to see you again. Nice to see you again doctor. So the last time I think I saw you was about six weeks ago and I had started some new chemotherapy medicines accommodation of taxol and herceptin. So after I started taking them, I started experiencing muscle aches in my shoulders arms and legs and also some numbness and tingling in my fingers hands toes and feet and I guess my question for you while it and they've actually gotten sort of progressively worse since I started on these medications. So I guess my question for you is what is this to be expected or is this unusual you that's the perfect question it is to be expected from it's a known side effect of taxol. Okay different people.Experience it two very different.So it's pretty rare that somebody doesn't have these side effects and it's the level of side effect that you're having is pretty typical Our concern when people have these side effects as whether they get bad enough to interfere with your ability to take care of yourself. Well actually to a certain extent they have because the seem to be getting more severe and it's getting difficult to say take a morning shower and get dressed and I have to walk down to the end of the driveway to get my mail and I've been actually having to use a cane to do that and I've noticed that if I rest or take a warm bath, it seems to diminish the symptoms somewhat and makes me feel better. So I don't know if they're any other recommendations that you would have to kind of help treat the symptoms. So this is great that you've been able toobserve yourself andModifications that have helped you and I would say Bravo keep doing that keep doing that kind of self-observation understanding by trial and error. Okay. Well what makes your symptoms better, there isn't a medical recommendation that I could make to you. It's just going to be a matter of you're figuring out how to get through your day with the tasks that you have to do in the best way possible. Okay. So I my concern is like since the symptoms of beginning worse. Is this sort of a plateau that I will reach at some point or is it like how how quickly or what's the time course of the progression of the symptom? Yep. What's your future look like? Yeah. What's the yeah, exactly. And so I'm in that uncomfortable place that doctors are all the time by saying well, it depends and well, there's a range of ways that this couldthe most common thing is thatWe finished the tax all your symptoms will get better and at least half of people symptoms go away completely for life and the other half still have a little residual but nothing like the degree that you're experiencing now. Okay. Well that sounds good. The things will get better that's gives me hope. Yeah, how would you say my cancer is doing overall? Well, the best way we have to look at that is the CT scan because we're trying to look at the effect of the attack saw and the herceptin on that nodule in your lung and the results of that scan word that things have stayed exactly as they have been so the nodules not getting bigger. Okay. It's also not getting smaller we would and I will interpret that as good news because the purpose of the chemotherapy was to stopFrom getting bigger because that's what was happening before.Of course, we hoped it would get smaller that it would not just stop it. It would turn around and we don't have good news in that regard. But overall we're getting benefit out of the chemotherapy and I think it's worth continuing. Okay. So you mentioned that there would stop the tax halt some some point and just continue on the herceptin was that part of the yes, that will be our plan because okay acceptance not giving you side effects. So we're going to balance our taxol with what's the standard treatment and your side effects because that could make us stop sooner. Okay, but not at this point. Okay still planning a six-month course six months. Okay. All right. Well, that's very good to know great. Well, what I would want to know is if these things are getting worse in any way such that you really are having trouble getting a shower getting your mail Etc. And so that you there things that you reach a limit withYou can't do in which case I would."


=begin
This is a really naive information extractor to detect assertions about disease statuses.

All it does is tag mentions of a list of disease-status-related keywords (disease, cancer, status), tag mentions of disease-status-related value words (e.g. stable, improving), and tag mentions of rationale concepts (e.g. imaging, scans, symptoms). For each keyword, it checks the next tag to the right, and if that tag is a status value, it returns the value. It also returns and normalizes all rationale mentions found within the chunk along with that status assertion.

So, it will assert "stable" for the phrase "your cancer is stable."

It will also do the right thing in slightly more complicated cases, for example, still correctly asserting "stable" and also correctly NOT assert "progressing" for the phrase "your disease is um stable it is not progressing."

=end

=begin
Example output:
[
    {
	"disease": null,
	"status": {
	    "mention text": "not changing",
	    "normalized": "stable"
	},
	"rationale": [
	    {
		"mention text": "CT scans",
		"normalized": "Imaging"
	    }
	]
    },
    {
	"disease": null,
	"status": {
	    "mention text": "progressing",
	    "normalized": "progressing"
	},
	"rationale": [
	    {
		"mention text": "CT scans",
		"normalized": "Imaging"
	    },
	    {
		"mention text": "physical exam",
		"normalized": "Physical Exam"
	    }
	]
    }
]
=end

class DiseaseStatusExtractor
  def analyze_text (text)
    annotated = Standoff::AnnotatedString.new( :signal => text, :tags => [])

    # this would be just key.match document, but we want MatchData for possible multiple keyword matches, not just one
    annotated.signal.to_enum(:scan, /status|disease|cancer|nodules?/i).map{ Regexp.last_match }.each do |match|
      annotated.tags << Standoff::Tag.new(:content => match[0],
                                          :name => "disease_status_key",
                                          :start => match.begin(0),
                                          :end => match.end(0) )
    end

    # TODO: this is dopey. duplication of search expressions between here and the disease_status patterns in Chunker should be abstracted and merged.
    annotated.signal.to_enum(:scan, /((not? )|(complete ))?(stable|progressing|responding|response( to treatment)?|resection|inevaluable|changed?|getting worse|worsening|getting better|improving|(stayed )?exactly (the same|as they have been))/i).map{ Regexp.last_match }.each do |match|
      mention_text = match[0]
      mapped_for_normalization = case mention_text # be very careful with this. it evaluates greedily, and as such the order of expressions here matters a lot.
                                # Problems: "not stable" normalizes to "Stable"
                                 when /^not? |^(stayed )?exactly/i
                                   "stable"
                                 when /getting worse|worsening|progress/i
                                   "progressing"
                                 when /complete resection/i, /complete response/i
                                   $&
                                 when /getting better|improving|response to treatment/i
                                   "responding"
                                 when /inevaluable/i, /stable/i, /progressing/i
                                   $&
                                 else
                                   nil
                                 end
      normalized = mapped_for_normalization ? mapped_for_normalization.split(/ |\_/).map(&:capitalize).join(" ") : nil#cap each word
      annotated.tags << Standoff::Tag.new(:content => match[0],
                                          :name => "status_value",
                                          :attributes => {:normalized => normalized},
                                          :start => match.begin(0),
                                          :end => match.end(0) )
    end

    annotated.signal.to_enum(:scan, /(( ca?t scan| ct |mri|x-ray|x ray|imaging)( results)?)/i).map{ Regexp.last_match }.each do |match|
      annotated.tags << Standoff::Tag.new(:content => match[0],
                                          :name => "status_rationale",
                                          :attributes => {:normalized => "Imaging"},
                                          :start => match.begin(0),
                                          :end => match.end(0) )
    end
    annotated.signal.to_enum(:scan, /(pathology|symptoms|(physical )?exam|markers)/i).map{ Regexp.last_match }.each do |match|
      mention_text = match[0]
      mention_text = "physical exam" if mention_text == "exam"
      normalized = mention_text.split(/ |\_/).map(&:capitalize).join(" ") #cap each word
      annotated.tags << Standoff::Tag.new(:content => mention_text,
                                          :name => "status_rationale",
                                          :attributes => {:normalized => normalized},
                                          :start => match.begin(0),
                                          :end => match.end(0) )
    end
    

    

    disease_status_assertions = []

    annotated.tags.select{|tag| tag.name == "disease_status_key"}.each do |key_tag|
      next_tag = annotated.next_tag key_tag
      if next_tag && (next_tag.name == "status_value")
        disease_status_assertions << {
          :disease => nil,
          :rationale => annotated.tags.select{|tag| tag.name == "status_rationale"}.map do|tag|
            {:mention_text => tag.content, :normalized => tag.attributes[:normalized]}
          end.uniq,
          :status => { :mention_text => next_tag.content,
                       :normalized => next_tag.attributes[:normalized]}
            
        }
      end
    end

    return disease_status_assertions
  end

end

#c = DiseaseStatusExtractor.new
#puts c.analyze_text(text).inspect
