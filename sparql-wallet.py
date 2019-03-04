#!/usr/bin/python
#
# Description:
# OnlineAccount accountName(s) of the document author
#
# Usage:
# ./sparwl-wallet.py <rdf_file> <dlt_name>
#
# Example:
# ./sparwl-wallet.py "bob.rdf" "namecoin:"
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
expStr = sys.argv[2]

g = Graph()
g.parse(profile_doc)

qres = prepareQuery(
   """SELECT DISTINCT ?oan
      WHERE {
        ?doc rdf:type foaf:PersonalProfileDocument ;
        foaf:maker ?author .
        ?author foaf:account ?account .
        ?account rdf:type foaf:OnlineAccount .
        ?account foaf:accountName ?oan .
        FILTER regex(str(?oan), '"""+expStr+"""', "i")
      }""", initNs = {'foaf':FOAF})

for row in g.query(qres):
    dlt,address = str(row[0]).split(':')
    print (address)

g.close()

