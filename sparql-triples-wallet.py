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
# import time

profile_doc = sys.argv[1]

g = Graph()
# start = time.time()
g.parse(profile_doc)
# mid = time.time()

# mid2 = time.time()

#print("--- printing raw triples ---")
#for subj, pred, obj in g:
#    print((subj, pred, obj))
#
#print("----------------------------")

for subj, pred, obj in g.triples((None,URIRef("https://w3id.org/cc#wallet"),None)):
        network,address = obj.split(":")
        print (address)

# end = time.time()

# print "file"
# print mid-start
# print "query"
# print end-mid2
