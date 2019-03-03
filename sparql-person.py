#!/usr/bin/python
# dependencies:
# pip install rdfextras rdflib

import sys
import rdflib
from rdflib import Graph
from rdflib.plugins.sparql import prepareQuery
from rdflib.namespace import RDF, FOAF
from rdflib import URIRef

profile_doc = sys.argv[1]

g = Graph()
g.parse(profile_doc)

qres = prepareQuery(
   """SELECT DISTINCT ?name
      WHERE {
        ?doc rdf:type foaf:PersonalProfileDocument ;
        foaf:maker ?author .
        ?author foaf:name ?name .
      }""", initNs = {'foaf':FOAF, 'rdf':RDF})

for row in g.query(qres):
        print("%s" % row)

g.close()
