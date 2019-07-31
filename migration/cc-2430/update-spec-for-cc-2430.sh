#!/bin/sh

# This is an idempotent script, i.e., it only modifies what/if it needs to.

# Change value of api:maxPageSize to 200.

perl -0777 -ne '

  s/api:maxPageSize "50"/api:maxPageSize "200"/;

print' $1
