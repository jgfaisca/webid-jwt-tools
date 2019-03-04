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
from rdflib.namespace import FOAF

profile_doc = sys.argv[1] 
expStr = sys.argv[2] 

g = Graph()
g.parse(profile_doc)

for subj, pred, obj in g.triples((None,FOAF.accountName,None)):
    if obj.startswith(expStr):
       dlt,address = obj.split(":")
       print(address)

g.close()

