# FluxNotesOnVoice
Voice Interface to Flux Notes


# NLP Information Extraction

Information extraction tools for FluxNotesOnVoice can be found in info-extraction/.This is (primarily) Ruby-based, with the following dependencies:

```gem install json, trollop
```

analyze_toxicity_in_full_text.rb is a command-line script illustrating usage. It can run on an input text file (e.g. transcription of the recording of an encounter):

```ruby analyze_toxicity_in_full_text.rb --outputFormat spreadsheet -f <INPUT_TEXT> -o <OUTPUT_FILENAME>
```

To run on direct text input, use:
```ruby analyze_toxicity_in_full_text.rb --outputFormat spreadsheet -f <INPUT_TEXT> -o <OUTPUT_FILENAME> 
```

If the output filename (-o or --output) is omitted, output defaults to STDIN (but will therefore mix what would normally be file output in with program status output that is always displayed to the console).

--outputFormat defaults to "spreadsheet" and may be omitted. Additional options will be added later (e.g. "json", "fhir").

Support is included for multiple analytic components, which can be optionally specified:

--components watson meddra
Default behavior (at present) is to use Watson as the sole analytic engine. MedDRA requires a third-party package implemented in python, which in turn has python requirements to be installed via pip (nltk, flask, flask-cors, requests, numpy).