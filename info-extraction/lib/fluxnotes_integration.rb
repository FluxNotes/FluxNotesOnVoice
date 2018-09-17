require 'json'
require 'byebug'
class FluxNotes
    def self.build_structured_phrase(phrase, fields) 
        raise ArgumentError.new("Phrase needs to be of type 'String'") if(!phrase.instance_of? String)     
        raise ArgumentError.new("fields needs to be of type 'Array'") if(!fields.instance_of? Array)
        fields_data = fields.map{ |field| "{name: '#{field[:name]}', value: '#{field[:value]}'}"}
        data = "{phrase: #{phrase}, fields: [#{fields_data.join(", ")}]}"
        return "flux_command('insert-structured-phrase', #{data})"
    end
end