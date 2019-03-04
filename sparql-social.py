#!/usr/bin/python
#
# Description
# Document maker social graph relations 
#
# Dependencies:
# pip install rdfextras rdflib
#

import sys
import rdflib
from rdflib import Graph
from rdflib.plugins.sparql import prepareQuery
from rdflib.namespace import FOAF

profile_doc = sys.argv[1]

g = Graph()
g.parse(profile_doc)

qres = prepareQuery(
    """SELECT DISTINCT ?aname ?bname
       WHERE {
          ?a foaf:knows ?b .
          ?a foaf:name ?aname .
          ?b foaf:name ?bname .
       }""", initNs = {'foaf':FOAF})

for row in g.query(qres):
    print("%s knows %s" % row)

g.close()
