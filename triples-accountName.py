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
from rdflib import Graph, URIRef
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

count = 0
for subj, pred, obj in g.triples((None,FOAF.name,None)):
    uri = URIRef(subj)
    if str(obj) == str(expStr):
       count += 1
       if count == 1:
    	  for subj, pred, obj in g.triples((uri,FOAF.accountName,None)):
              print(obj)
    	      break

g.close()
sys.exit(0)
