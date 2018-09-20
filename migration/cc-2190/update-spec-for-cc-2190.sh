#!/bin/sh

# This is an idempotent script, i.e., it only modifies what/if it needs to.

# Override default JSON formatter so as to get date/time values in ISO 8601 format.
# Insert definition of conceptSearchEndPoint based on existing resourceEndPoint.
# Add dcterms:created and dcterms:modified to the svoc:basicConceptViewer.
# Change type of dcterms:created to xsd:dateTime.
# Change type of dcterms:modified to xsd:dateTime.

perl -0777 -ne '

  s/## end of TODO:\n##############################################################\n\n\t; api:endpoint\n                # ANDS: uncomment as needed\.\n\t\t# svoc:LandingPage ,/## end of TODO:\n##############################################################\n\n        # ANDS override of default JSON formatter,\n        # so as to get date\/time values in ISO 8601 format\.\n        ; api:formatter \[\n                a api:JsonFormatter\n                ; api:name "json"\n                ; api:mimeType "application\/json"\n                ; elda:jsonUsesISOdate true\n        \]\n\t; api:endpoint\n                # ANDS: uncomment as needed.\n\t\t# svoc:LandingPage ,/;


  s/(, \[api:name "resourceEndPoint"; api:value "{webapp}\/([a-z0-9\.\/_-]+)\/resource"\])(\n\t\t, \[api:name "serviceTitle";)/$1\n                # ANDS-specific: a list endpoint that supports filters. Used\n                # by searchURI-mode template in ands-ashtml-sissvoc.xsl.\n                , \[api:name "conceptSearchEndPoint"; api:value "{webapp}\/$2\/concept"\]$3/;


  s/svoc:basicConceptViewer a api:Viewer\n    ; api:name "concept"\n    ; api:property skos:prefLabel, skos:notation,\n      \( skos:broader skos:prefLabel \), skos:definition,\n      \( skos:narrower skos:prefLabel \)\n    \./svoc:basicConceptViewer a api:Viewer\n    ; api:name "concept"\n    ; api:property skos:prefLabel, skos:notation,\n      \( skos:broader skos:prefLabel \), skos:definition,\n      \( skos:narrower skos:prefLabel \),\n      dcterms:created, dcterms:modified\n    ./;


  s/dcterms:created\n                api:label "dctermsCreated" ;\n                a      rdfs:Property ;\n                rdfs:range     rdfs:Literal ./dcterms:created\n                api:label "dctermsCreated" ;\n                a      rdfs:Property ;\n                rdfs:range     xsd:dateTime ./;

  s/dcterms:modified\n                api:label "dctermsModified" ;\n                a      rdfs:Property ;\n                rdfs:range     rdfs:Literal ./dcterms:modified\n                api:label "dctermsModified" ;\n                a      rdfs:Property ;\n                rdfs:range     xsd:dateTime ./;

print' $1
