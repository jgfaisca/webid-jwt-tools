#!/usr/bin/python
#
# Description:
# This script will print the accountName of a FOAF account
#
# Usage:
# ./script-name.py <rdf_file> <foaf_name>
#
# rdf_file  ->    RDF file name
# foaf_name ->    foaf:name value
#
# Example:
# ./script-name.py "bob.rdf" "namecoin"
#
# Dependencies:
# pip install rdflib rdfextras
#
# Authors:
# Jose G. Faisca <jose.faisca@gmail.com>
#

import sys, os
import rdflib
from rdflib import Graph
from rdflib.plugins.sparql import prepareQuery
from rdflib.namespace import FOAF

if ((len(sys.argv) != 3)):
    print ("""\
This script will print the accountName
of a FOAF account

Usage: %s <rdf_file> <foaf_name>

rdf_file  ->    RDF file name
foaf_name ->    foaf:name value
""" % os.path.basename(sys.argv[0]))
    sys.exit(1)

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
	?account foaf:name ?name .
        ?account foaf:accountName ?oan .
        FILTER regex(str(?name), '"""+expStr+"""', "i")
      } LIMIT 1 """, initNs = {'foaf':FOAF})

for row in g.query(qres):
    print ("%s" % row)

g.close()
sys.exit(0)
