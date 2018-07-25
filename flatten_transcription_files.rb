#!/ruby

# Input: text file containing transcribed speech for one recording, broken into multiple lines, possibly with speaker designations (e.g. "Speaker 1:") inline.

# Output: text file with same name appended with ".flattened" with all line breaks and speaker designations removed


filename = ARGV[0]

document = File.new(filename).read

document.gsub! "\n", " "
document.gsub! "\r", " "
document.gsub! /Speaker \d: /, ""

File.open(filename + ".flattened", 'w') {|out| out.puts document}



