require 'standoff'

=begin
This is a really naive information extractor to detect assertions about disease statuses.

All it does is tag mentions of a list of disease-status-related keywords (disease, cancer, status), tag mentions of disease-status-related value words (e.g. stable, improving). For each keyword, it checks the next tag to the right, and if that tag is a status value, it returns the value.

So, it will assert "stable" for the phrase "your cancer is stable."

It will also do the right thing in slightly more complicated cases, for example, still correctly asserting "stable" and also correctly NOT assert "progressing" for the phrase "your disease is um stable it is not progressing."

=end

class DiseaseStatusExtractor
  def analyze_text (text)
    annotated = Standoff::AnnotatedString.new( :signal => text, :tags => [])

    # this would be just key.match document, but we want MatchData for possible multiple keyword matches, not just one
    annotated.signal.to_enum(:scan, /status|disease|cancer/).map{ Regexp.last_match }.each do |match|
      annotated.tags << Standoff::Tag.new(:content => match[0],
                                          :name => "disease_status_key",
                                          :start => match.begin(0),
                                          :end => match.end(0) )
    end
    
    annotated.signal.to_enum(:scan, /(not )?(stable|progressing|getting worse|worsening|getting better|improving)/).map{ Regexp.last_match }.each do |match|
      annotated.tags << Standoff::Tag.new(:content => match[0],
                                          :name => "status_value",
                                          :start => match.begin(0),
                                          :end => match.end(0) )
    end

    disease_status_assertions = []
    annotated.tags.select{|tag| tag.name == "disease_status_key"}.each do |key_tag|
      next_tag = annotated.next_tag key_tag
      if next_tag.name == "status_value"
        disease_status_assertions << next_tag.content
      end
    end

    return disease_status_assertions
  end

end
