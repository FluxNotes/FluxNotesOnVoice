class Meddra4Fluxnotes
  def initialize (third_party_meddra_root_dir)
    @third_party_meddra_root_dir = third_party_meddra_root_dir
  end
  def analyze_text (text, score_threshold)
    # call out to python script which returns the best disease mention candidate for each ngram in the text:
    concepts =  JSON.parse `echo \"#{text}\" | python #{File.dirname(__FILE__)}/meddra_ngram_lookup.py --fluxnotes_nlp_ensemble_dir=#{@third_party_meddra_root_dir}`# TODO: make this safer. at the moment, we're relying on the fact that ASR output isn't going to contain special execution characters, but it would be better to feed the input string to the python directly
    concepts = filter! concepts, score_threshold
    concepts
  end

  def filter! (extracted_concepts, score_threshold)
    # remove non-disease terms:
    extracted_concepts.select!{|c| has_relevant_meddra_concept_type c}
    # remove terms with low match weight (Sam warns: these weights are not really intended to be normalized; however, they do seem to be comparable enough for initial use)
    extracted_concepts.select!{|c| c["score"] > score_threshold}
    # consolidate multiple extracted mentions of each unique concept:
    extracted_concepts = extracted_concepts.group_by{|c| c["term"]}.map do |unique_concept, mentions|
      best_mention = mentions.sort_by{|m| m["score"]}.last
    end
    extracted_concepts
  end

  def has_relevant_meddra_concept_type ( concept )
    # TODO: this is a placeholder; it should be replaced by actually checking the MedDRA concept hierarchy
    # this is a manually curated, example-specific list. the fluxnotes meddra lookup is currently returning some concepts that are not diseases/symptoms.
    concepts_known_not_to_be_disease = [
      "Adverse drug reaction",
      "Computerised tomogram",
      "Self-medication",
      "Multiple use of single-use product",
      "Beta-N-acetyl-D-glucosaminidase"
    ]
    
    if concepts_known_not_to_be_disease.include? concept["term"]
      return false
    else
      return true
    end
  end

end
