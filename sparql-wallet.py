#!/usr/bin/python
# dependencies:
# pip install rdfextras rdflib

import sys
import rdflib
from rdflib import Graph

profile_doc = sys.argv[1] 
expStr = sys.argv[2] 

g = Graph()
g.parse(profile_doc)

# OnlineAccount accountName(s) of the document author
qres = g.query(
   """SELECT DISTINCT ?oan
      WHERE {
        ?doc rdf:type foaf:PersonalProfileDocument ;
        foaf:maker ?author .
        ?author foaf:account ?account .
        ?account rdf:type foaf:OnlineAccount .
        ?account foaf:accountName ?oan .
        FILTER regex(str(?oan), '"""+expStr+"""', "i")
      }""")

for row in qres:
    network,address = str(row[0]).split(':')
    print (address)

g.close()
