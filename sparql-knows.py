#!/usr/bin/python
#
# dependencies:
# pip install rdfextras rdflib
#

import sys
import rdflib
from rdflib import Graph
from rdflib.plugins.sparql import prepareQuery
from rdflib.namespace import FOAF, RDFS

profile_doc = sys.argv[1]

g = Graph()
g.parse(profile_doc)

qres = prepareQuery(
   """SELECT DISTINCT ?url
      WHERE {
        ?doc rdf:type foaf:PersonalProfileDocument ;
        foaf:maker ?author .
        ?author foaf:knows ?someone .
        ?someone foaf:name ?name .
	?someone rdfs:seeAlso ?url .
      }""", initNs = {'foaf':FOAF, 'rdfs':RDFS})

for row in g.query(qres):
    print("%s" % row)

g.close()

