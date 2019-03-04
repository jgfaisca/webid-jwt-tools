#!/usr/bin/python
#
# dependencies:
# pip install rdfextras rdflib
#
# Authors:
# Jose G. Faisca <jose.faisca@gmail.com>
#

import sys
import rdflib
from rdflib import Graph
from rdflib import URIRef
from rdflib.namespace import FOAF

profile_doc = sys.argv[1]

g = Graph()
g.parse(profile_doc)

for subj, pred, obj in g.triples((None,FOAF.maker,None)):
   uri = URIRef(obj)

for subj, pred, obj in g.triples((uri,FOAF.name,None)):
   print(obj)

g.close()

