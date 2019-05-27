#!/bin/sh

# This is an idempotent script, i.e., it only modifies what/if it needs to.

# Change "ANDS" to "ARDC" in comments and in service information.
# Don't change variable names.

# 1. Replace "ANDS", but not "_ANDS".
# 2. Replace services email address.
# 3. Replace web site.

perl -0777 -ne '

  s/([^_])ANDS/\1ARDC/g;
  s/services\@ands.org.au/services\@ardc.edu.au/;
  s|http://www.ands.org.au|https://ardc.edu.au|;

print' $1
