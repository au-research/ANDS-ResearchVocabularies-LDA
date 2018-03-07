# ANDS usage of SISSVoc

## References

* Public repository of ANDS customizations:
  https://github.com/au-research/ANDS-ResearchVocabularies-LDA

## Deployments

* Production: Research Vocabularies Australia (RVA)
  https://vocabs.ands.org.au/
    * Sample:
      http://vocabs.ands.org.au/repository/api/lda/aodn/aodn-discovery-parameter-vocabulary/version-1-2/concept
* Demo: https://demo.ands.org.au/vocabs/

## Explanation of ANDS customizations

### How we got started

We "bootstrapped" by cloning the repo at
https://github.com/CSIRO-enviro-informatics/sissvoc-package.git
and following the instructions in the `README.md`. I.e., we used the
`package-sissvoc-vanilla.sh`.

To get this to work for us, we had to edit
`package-sissvoc-vanilla--no-build.sh` to use the command `python3`
intead of `python`: the `gen_sissvoc3_config.py` requires Python 3,
and the default Python on our servers was/is 2.7.

### Background

Through SISSVoc we make available some "fixed" endpoints for what we
call _curated_ vocabularies: special endpoints that "have to work" for
us, because they support Research Data Australia. (In fact, RDA now
has its own caches of curated vocabulary data, so it no longer hits
RVA.)

### `common`

Overrides common to all our servers. These replace or add to the
contents of the generated WAR file.

#### `common/WEB-INF/web.xml`

We set `com.epimorphics.api.initialSpecFile` to
`resources/default/config/*.ttl,/var/vocab-files/registry-data/specs/*.ttl`.

The former directory contains the "hard-coded" spec files for the
"curated" vocabularies; the latter directory is where RVA puts each
generated spec file during the publication process.

#### `common/WEB-INF/lib`

We use a recent release of the Elda library, currently 1.3.23.
We drop this in on top of the JAR file fetched as part of the SISSVoc
build process.

#### `common/resources/default`

* css: overrides to use our own banner, fix word wrapping issues
* images: our banner, and some otherwise-missing images
* transform: our custom ands-ashtml-sissvoc.xsl. It imports the
  `ashtml-sissvoc.xsl` stylesheet and then overrides certain
  templates.

### `servers`

Overrides that are server-specific.

#### `servers/vocabs/resources/default/config`

The "hard-coded" spec files for our "curated" vocabularies, for our
production server (RVA).

### source

* `resources/default/images`: The SVG source of our banner, used to
  generate the banner in PNG format in
  `common/resources/default/images`.

## What's _not_ here

This repository doesn't include the template used to generate spec
files for vocabularies published by RVA. You can find that here:
https://github.com/au-research/ANDS-ResearchVocabularies-Registry/blob/master/conf/ANDS-ELDAConfig-template.ttl.sample

The customizations in that file are:

* Customized header to specify the vocabulary title, "more
  information", and (not used) a link to further documentation about
  the vocabulary.
* Customized basic concept viewer that gets labels for narrower and
  broader concepts.
* Customized concept scheme viewer that gets labels for top concepts.
* Extra endpoints:
    * `/concept/topConcepts` to fetch all top concepts of all concept
      schemes, using `skos:hasTopConcept`.
    * `concept/topConcepts?scheme={scheme_uri}` to fetch top concepts
      of one concept scheme.
    * `/concept?anycontains={text}` to fetch concepts where the label
      (either `rdfs:label` or `skos:prefLabel` or `skos:altLabel`)
      or notation, or the concept's IRI contains some text.
    * `/concept/inCollection?uri={baseCollection}` to fetch concepts
      in a SKOS collection, using `skos:member`.
    * `/concept/allBroader?uri={baseConcept}` to fetch broader
      concepts using the transitive closure of `skos:narrower` (yes,
      in reverse, not `skos:broader` directly)
    * `/concept/allNarrower?uri={baseConcept}` to fetch narrower
      concepts using the transitive closure of `skos:broader` (yes,
      in reverse, not `skos:narrower` directly)
* Definitions of some "popular" properties (from DC Elements and DC
  Terms) so that appear more nicely (?) in generated results.
