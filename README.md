# ANDS-Vocabs-LDA

ANDS provides access to published vocabularies through the Linked Data
API.  (Refer to the
[Linked Data API Specification](https://github.com/UKGovLD/linked-data-api/blob/wiki/Specification.md).)

ANDS's implementation of the Linked Data API is based on the elda
library (https://github.com/epimorphics/elda), customized further as
SISSVoc (https://github.com/SISS/sissvoc and https://github.com/CSIRO-enviro-informatics/sissvoc-package).

This repository stores ANDS's further local customizations.

Directory structure:

* common:
  customizations applied to all of ANDS's installations
* servers:
  customizations as applied to particular ANDS servers. Each
  server requiring special treatment has its own subdirectory.
* scripts:
  scripts to copy the customizations into place.
* source:
  source for a customization, where that source is not otherwise
  to be copied into the installation
