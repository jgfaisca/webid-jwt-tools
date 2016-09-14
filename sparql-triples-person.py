#!/usr/bin/python
# dependencies:
# pip install rdfextras rdflib rdflib-sparql
#
# Authors: 
# Norman Radtke <radtke@informatik.uni-leipzig.de>
# Jose G. Faisca <jose.faisca@gmail.com>
#

import sys
import rdflib
from rdflib import Graph
from rdflib import URIRef
# import time

profile_doc = sys.argv[1]

g = Graph()
# start = time.time()
g.parse(profile_doc)
# mid = time.time()

# mid2 = time.time()

for s, p, o in g.triples((None,URIRef("http://xmlns.com/foaf/0.1/name"),None)):
   print(o)

# end = time.time()
