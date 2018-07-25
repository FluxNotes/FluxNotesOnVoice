from nltk import ngrams

import json

import getopt

import os, sys

def usage():
    print >> sys.stderr, "Usage: meddra_ngram_lookup.py --fluxnotes_nlp_ensemble_dir=<ROOT_DIR>"
    sys.exit(1)
            

try:
    opts, args = getopt.getopt(sys.argv[1:], 'd', ['fluxnotes_nlp_ensemble_dir=', 'help'])
except getopt.GetoptError:
    usage()
    sys.exit(2)

for opt, arg in opts:
    if opt in ('-h', '--help'):
        usage()
        sys.exit(2)
    elif opt in ('-d', '--fluxnotes_nlp_ensemble_dir'):
        DEMO_ROOT = arg
    else:
        print opt
        print arg
        usage()
        sys.exit(2)

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
