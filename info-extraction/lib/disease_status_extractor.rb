require 'standoff'

=begin
This is a really naive information extractor to detect assertions about disease statuses.

All it does is tag mentions of a list of disease-status-related keywords (disease, cancer, status), tag mentions of disease-status-related value words (e.g. stable, improving). For each keyword, it checks the next tag to the right, and if that tag is a status value, it returns the value.

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
    annotated.signal.to_enum(:scan, /status|disease|cancer/i).map{ Regexp.last_match }.each do |match|
      annotated.tags << Standoff::Tag.new(:content => match[0],
                                          :name => "disease_status_key",
                                          :start => match.begin(0),
                                          :end => match.end(0) )
    end

    # TODO: this is dopey. duplication of search expressions between here and the disease_status patterns in Chunker should be abstracted and merged.
    annotated.signal.to_enum(:scan, /((not? )|(complete ))?(stable|progressing|responding|response( to treatment)?|resection|inevaluable|changed?|getting worse|worsening|getting better|improving)/i).map{ Regexp.last_match }.each do |match|
      mention_text = match[0]
      mapped_for_normalization = case mention_text # be very careful with this. it evaluates greedily, and as such the order of expressions here matters a lot.
                                 when /^not? /i
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

    annotated.signal.to_enum(:scan, /((ca?t scan|mri|x-ray|x ray|imaging)( results)?)/i).map{ Regexp.last_match }.each do |match|
      annotated.tags << Standoff::Tag.new(:content => match[0],
                                          :name => "status_rationale",
                                          :attributes => {:normalized => "Imaging"},
                                          :start => match.begin(0),
                                          :end => match.end(0) )
    end
    annotated.signal.to_enum(:scan, /(pathology|symptoms|(physical )?exam|markers)/i).map{ Regexp.last_match }.each do |match|
      mention_text = m[0]
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
