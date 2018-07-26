class FindingsCollector
  attr_accessor :findings
  def initialize
    @findings = []
    @key_order = [:text, :target_category, :analytic_source, :feature, :type, :score, :context]
  end
  def << (values)
    # values should be a hash including the following (but it's ok to omit things):
    # text: normalized label for the concept
    # analytic_source: system that extracted the concept e.g. Watson, MedDRA
    # feature: e.g. Entity, Concept
    # code: e.g. Peripheral_neuropathy as a DBpedia reference, 
    # type: e.g. Disease
    # score: system confidence/weight (not comparable across analytic sources
    # context: the full text span from which this concept was extracted
    @findings << values
  end
  def puts (ostream, format)
    case format
    when "spreadsheet"
      @findings.each do |f|
        ostream.puts @key_order.map{|k| f[k]}.join("\t")
      end
    end
  end
end
