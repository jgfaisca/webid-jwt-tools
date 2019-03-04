#!/usr/bin/python
#
# dependencies:
# pip install rdfextras rdflib rdflib-sparql
#
# Authors: 
# Jose G. Faisca <jose.faisca@gmail.com>
#

import sys
import rdflib
from rdflib import Graph
from rdflib import URIRef
#from rdflib import Namespace
#from rdflib.plugins.sparql import prepareQuery
#from rdflib.namespace import RDF, FOAF


profile_doc = sys.argv[1]
# regex string
expStr1 = "/ipns/"
expStr2 = "namecoin:"

g = Graph()
g.parse(profile_doc)

print("--- printing raw triples ---")
for subj, pred, obj in g:
    print((subj, pred, obj))

print("----------------------------")

# names of the persons whom the author of the document knows
qres = g.query(
   """SELECT DISTINCT ?name
      WHERE {
 	?doc rdf:type foaf:PersonalProfileDocument ;
        foaf:maker ?author .
        ?author foaf:knows ?someone .
        ?someone foaf:name ?name .
      }""")

print ("* Names of the persons whom the author of the document knows *")
for row in qres:
    print("%s" % row)
    # JSON output
    #print("json", qres.serialize(format="json"))

print("----------------------------")

# names of the persons and resources whom the author of the document knows
qres = g.query(
   """SELECT DISTINCT ?name ?url
      WHERE {
        ?doc rdf:type foaf:PersonalProfileDocument ;
        foaf:maker ?author .
        ?author foaf:knows ?someone .
        ?someone foaf:name ?name .
	?someone rdfs:seeAlso ?url .
      }""")

print ("* Names of the persons and resources whom the author of the document knows *")
for row in qres:
    print("%s  %s" % row)

print("----------------------------")

# check resource
qres = g.query(
   """SELECT DISTINCT ?name ?url
      WHERE {
        ?doc rdf:type foaf:PersonalProfileDocument ;
        foaf:maker ?author .
        ?author foaf:knows ?someone .
        ?someone foaf:name ?name .
	?someone rdfs:seeAlso ?url .
	FILTER regex(str(?url), '"""+expStr1+"""', "i")
      }""")

print ("* Names of the persons and IPFS (/ipns/) resources whom the author of the document knows *")
for row in qres:
    print("%s %s" % row)

print("----------------------------")

# name of the document author
qres = g.query(
   """SELECT DISTINCT ?name
      WHERE {
        ?doc rdf:type foaf:PersonalProfileDocument ;
        foaf:maker ?author .
        ?author foaf:name ?name .
      }""")

print ("* Name of the document author *")
for row in qres:
    print("%s" % row)

print("----------------------------")

# homepage of the document author
qres = g.query(
   """SELECT DISTINCT ?homepage
      WHERE {
        ?doc rdf:type foaf:PersonalProfileDocument ;
        foaf:maker ?author .
        ?author foaf:homepage ?homepage .
      }""")

print ("* Homepage of the document author")
for row in qres:
    print("%s" % row)

print("----------------------------")

# wallet(s) address  of the document author
qres = g.query(
   """SELECT DISTINCT ?address
      WHERE {
        ?doc rdf:type foaf:PersonalProfileDocument ;
        foaf:maker ?author .
        ?author cc:wallet ?address .
      }""")

print ("* Wallet address of the document author *")
for row in qres:
    print("%s" % row)

print("----------------------------")

# OnlineAccount accountName(s) of the document author
qres = g.query(
   """SELECT DISTINCT ?oan
      WHERE {
        ?doc rdf:type foaf:PersonalProfileDocument ;
        foaf:maker ?author .
        ?author foaf:account ?account .
        ?account rdf:type foaf:OnlineAccount .
        ?account foaf:accountName ?oan
      }""")

print ("* OnlineAccount accountName(s) of the document author *")
for row in qres:
    print("%s" % row)

print("----------------------------")

# OnlineAccount name(s) of the document author
qres = g.query(
   """SELECT DISTINCT ?on
      WHERE {
        ?doc rdf:type foaf:PersonalProfileDocument ;
        foaf:maker ?author .
        ?author foaf:account ?account .
        ?account rdf:type foaf:OnlineAccount .
        ?account foaf:name ?on .
      }""")

print ("* OnlineAccount name(s) of the document author *")
for row in qres:
    print("%s" % row)

print("----------------------------")

# About OnlineAccount(s) of the document author
print ("* About account(s) document author *")
for subj, pred, obj in g.triples((None,URIRef("http://xmlns.com/foaf/0.1/account"),None)):
   print(obj)

print("----------------------------")

# OnlineAccount accountName(s) of the document author
qres = g.query(
   """SELECT DISTINCT ?oan
      WHERE {
        ?doc rdf:type foaf:PersonalProfileDocument ;
        foaf:maker ?author .
        ?author foaf:account ?account .
        ?account rdf:type foaf:OnlineAccount .
        ?account foaf:accountName ?oan .
	FILTER regex(str(?oan), '"""+expStr2+"""', "i")
      }""")

print ("* OnlineAccount (namecoin:) accountName(s) of the document author *")
for row in qres:
    #print("%s" % row)
    network,address = str(row[0]).split(':')
    print (address)

print("----------------------------")

# social network
qres = g.query(
    """SELECT DISTINCT ?aname ?bname
       WHERE {
          ?a foaf:knows ?b .
          ?a foaf:name ?aname .
          ?b foaf:name ?bname .
       }""")

print ("* Author social relations *")
for row in qres:
    print("%s knows %s" % row)

print("----------------------------")

