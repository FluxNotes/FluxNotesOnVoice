from nltk import ngrams

import json

import os, sys
DEMO_ROOT = os.path.dirname("/home/davidtk/moonie/fluxnotes_nlp_ensemble/")
sys.path.insert(0, os.path.join(DEMO_ROOT, "lib", "python"))
import fluxnotes_nlp
from fluxnotes_nlp.meddra import MedDRADB, MedDRADBError
meddra = fluxnotes_nlp.meddra.MedDRADB()


for line in sys.stdin:
#    print line
    trigrams = ngrams(line.split( ), 3)
    results = []
    for trigram in trigrams:
#        print trigram
        result = meddra.searchWithString(" ".join(trigram))
        if result is None: # Should investigate why this is happening sometimes on well-formed trigrams. seems like a bug. just skipping these for now as they're rare.
            continue
#        print result
        result['mention'] = trigram
        results.append(result)
    print json.dumps(results)
