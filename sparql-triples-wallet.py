#!/usr/bin/python
# dependencies:
# pip install rdfextras rdflib rdflib-sparql
#
# Authors:
# Jose G. Faisca <jose.faisca@gmail.com>

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

#print("--- printing raw triples ---")
#for s, p, o in g:
#    print((s, p, o))
#
#print("----------------------------")

for s, p, o in g.triples((None,URIRef("https://w3id.org/cc#namecoin"),None)):
   print(o)

# end = time.time()

# print "file"
# print mid-start
# print "query"
# print end-mid2
