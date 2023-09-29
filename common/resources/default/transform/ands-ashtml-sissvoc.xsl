<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fn="http://www.w3.org/2005/xpath-functions">

  <!-- This is the ANDS custom XSL transform to produce the HTML
       pages for SISSVoc. It is implemented as a set of overrides
       of the original SISSVoc stylesheet. -->
  
  <!-- First, import the original SISSVoc stylesheet -->
  <xsl:import href="ashtml-sissvoc.xsl" />

  <!-- Now, apply the ANDS customizations as patches. -->

  <!-- Patch 1 -->
  <!-- These are not overrides, but additional variables that can
       be set in a spec file. They are used by Patch 3. -->
  <xsl:param name="_ANDS_vocabName">Unnamed Vocabulary</xsl:param>
  <xsl:param name="_ANDS_vocabMore" />
  <xsl:param name="_ANDS_vocabAPIDoco" />

  <!-- Patch 2 -->
  <!-- Adjust the path to favicon.ico. -->
  <xsl:template match="result" mode="meta">
    <link rel="shortcut icon" href="/favicon.ico" type="image/x-icon" />
    <xsl:apply-templates select="first | prev | next | last"
                         mode="metalink" />
    <xsl:apply-templates select="hasFormat/item" mode="metalink" />
  </xsl:template>

  <!-- Patch 3 -->
  <!-- Discard the original setting of the h1 header, and use the
       additional variables supported by Patch 1, if provided.
       Move the formats to the header.
       Note: the span.image must have _some_ content in it, otherwise
       it "disappears" (i.e., together with the background image.

       The gunk for the RVA logo is copied from the Portal, so that
       the position of the logo exactly matches.
  -->
  <xsl:template match="result" mode="header">

    <div class="nav-site-container">
      <nav class="site">

	<div style="float:left">
	  <div style="display: inline-flex">
	    <span style="display: inline-block; height: 100%; vertical-align: middle"></span>
	    <a style="vertical-align: middle; outline: 0" href="/">
	      <img style="vertical-align: middle; min-width: 150px"
		   src="{$myResourceImagesBase}/ARDC_Research_Vocabularies_RGB_FA_Master.svg"
		   width="300px" />
	    </a>
	  </div>
	</div>
	<section class="lda-heading">
	  <span>Linked Data API</span>
	  <span class="image"><br /></span>
	</section>
      </nav>
    </div>

    <div id="page-header-border">
      <div id="page-header">
	<header>
	  <h1 class="vocab-title"><xsl:value-of select="$_ANDS_vocabName"/></h1>
	</header>
      </div>
    </div>
  </xsl:template>

  <!-- Patch 4 -->
  <!-- Show labels for nested resources, as implemented
       by Leo: https://github.com/epimorphics/elda/issues/143
  -->
  <xsl:template match="*[@href]" mode="content">
    <xsl:param name="nested" select="false()" />
    <xsl:choose>
      <xsl:when test="$nested">
	<xsl:apply-templates select="." mode="table" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="/result/items/item[@href = current()/@href]">
            <xsl:apply-templates
                select="/result/items/item[@href = current()/@href]"
                mode="link">
              <xsl:with-param name="content">
                <xsl:apply-templates
                    select="/result/items/item[@href = current()/@href]"
                    mode="name"/>
              </xsl:with-param>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
	    <xsl:apply-templates select="." mode="link">
	      <xsl:with-param name="content">
	        <xsl:call-template name="lastURIpart">
	          <xsl:with-param name="uri" select="@href" />
	        </xsl:call-template>
	      </xsl:with-param>
	    </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Sigh. Because import precedence takes "priority" over numbered
       priorities, we must also import all of the other templates with
       mode="content", leaving them unchanged.
       Therefore, when the original ashtml-sissvoc.xsl is updated,
       must check to see if any of these templates has been touched;
       if so, copy the updated versions here.
  -->

  <xsl:template match="result" mode="content" priority="10">
	<xsl:apply-templates select="." mode="topnav" />
	<div id="result">
		<div class="panel">
			<xsl:choose>
				<xsl:when test="items">
					<header><h1>Search Results</h1></header>
					<xsl:apply-templates select="items" mode="content" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="primaryTopic" mode="content" />
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</div>
	<xsl:apply-templates select="." mode="bottomnav" />
</xsl:template>

<xsl:template match="/result/primaryTopic" mode="content" priority="10">
	<header>
		<h1><xsl:apply-templates select="." mode="name" /></h1>
		<p class="id"><a href="{@href}"><xsl:value-of select="@href" /></a></p>
	</header>
	<section>
		<xsl:apply-templates select="." mode="header" />
		<xsl:apply-templates select="." mode="table" />
		<xsl:apply-templates select="." mode="footer" />
	</section>
</xsl:template>

<xsl:template match="items" mode="content" priority="10">
	<xsl:choose>
		<xsl:when test="item[@href]">
			<xsl:apply-templates mode="section" />
		</xsl:when>
		<xsl:otherwise>
			<section>
				<p>No results</p>
			</section>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="items/item" mode="content" priority="20">
	<xsl:apply-templates select="." mode="table" />
</xsl:template>

<xsl:template match="*[item]" mode="content" priority="4">
	<xsl:param name="nested" select="false()" />
	<xsl:variable name="label" select="key('propertyTerms', $label-uri)/label" />
	<xsl:variable name="prefLabel" select="key('propertyTerms', $prefLabel-uri)/label" />
	<xsl:variable name="altLabel" select="key('propertyTerms', $altLabel-uri)/label" />
	<xsl:variable name="name" select="key('propertyTerms', $name-uri)/label" />
	<xsl:variable name="title" select="key('propertyTerms', $title-uri)/label" />
	<xsl:variable name="isLabelParam">
		<xsl:apply-templates select="." mode="isLabelParam" />
	</xsl:variable>
	<xsl:variable name="anyItemHasNonLabelProperties">
		<xsl:apply-templates select="." mode="anyItemHasNonLabelProperties" />
	</xsl:variable>
	<xsl:variable name="anyItemIsHighestDescription">
		<xsl:apply-templates select="." mode="anyItemIsHighestDescription" />
	</xsl:variable>
	<xsl:choose>
		<xsl:when test="$anyItemHasNonLabelProperties = 'true' and $anyItemIsHighestDescription = 'true'">
			<xsl:for-each select="item">
				<xsl:sort select="*[name(.) = $prefLabel]" />
				<xsl:sort select="*[name(.) = $name]" />
				<xsl:sort select="*[name(.) = $title]" />
				<xsl:sort select="*[name(.) = $label]" />
				<xsl:sort select="*[name(.) = $altLabel]" />
				<xsl:sort select="@href" />
				<xsl:apply-templates select="." mode="content">
					<xsl:with-param name="nested" select="$nested" />
				</xsl:apply-templates>
			</xsl:for-each>
		</xsl:when>
		<xsl:otherwise>
			<table>
				<xsl:for-each select="item">
					<xsl:sort select="*[name(.) = $prefLabel]" />
					<xsl:sort select="*[name(.) = $name]" />
					<xsl:sort select="*[name(.) = $title]" />
					<xsl:sort select="*[name(.) = $label]" />
					<xsl:sort select="*[name(.) = $altLabel]" />
					<xsl:sort select="@href" />
					<xsl:apply-templates select="." mode="row" />
				</xsl:for-each>
			</table>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="*[*]" mode="content" priority="3">
	<xsl:param name="nested" select="false()" />
	<xsl:variable name="hasNonLabelProperties">
		<xsl:apply-templates select="." mode="hasNonLabelProperties" />
	</xsl:variable>
	<xsl:variable name="isHighestDescription">
		<xsl:apply-templates select="." mode="isHighestDescription" />
	</xsl:variable>
	<xsl:choose>
		<xsl:when test="$nested or ($hasNonLabelProperties = 'true' and $isHighestDescription = 'true')">
			<xsl:apply-templates select="." mode="table" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="." mode="link">
				<xsl:with-param name="content">
					<xsl:apply-templates select="." mode="name" />
				</xsl:with-param>
			</xsl:apply-templates>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- Note: as of the application of Patch 10, we no longer need to include this one here:
<xsl:template match="*" mode="content">
	<xsl:value-of select="." />
</xsl:template>
-->

  <!-- End of verbatim-copied templates. -->


  <!-- Patch 5 -->
  <!-- Remove "magnifying glass" search links by removing the _first_
       element like this:
       <a rel="nofollow" title="more like this">...
       (The original template has also been reformatted here.)

       See CC-2089 for a proposed change (to do with specifying the
       vocabulary's languages in its spec file), which, if
       implemented, would allow restoration of these search links.
  -->
  <xsl:template match="*" mode="filter">
    <xsl:param name="paramName">
      <xsl:apply-templates select="." mode="paramName" />
    </xsl:param>
    <xsl:param name="value" select="." />
    <xsl:param name="label">
      <xsl:apply-templates select="." mode="value" />
    </xsl:param>
    <xsl:param name="datatype" select="@datatype" />
    <xsl:param name="hasNonLabelProperties">
      <xsl:apply-templates select="." mode="hasNonLabelProperties" />
    </xsl:param>
    <xsl:param name="hasNoLabelProperties">
      <xsl:apply-templates select="." mode="hasNoLabelProperties" />
    </xsl:param>
    <xsl:variable name="paramValue">
      <xsl:call-template name="paramValue">
	<xsl:with-param name="uri">
	  <xsl:apply-templates select="/result" mode="searchURI" />
	</xsl:with-param>
	<xsl:with-param name="param" select="$paramName" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$value = ''" />
      <xsl:when test="$hasNonLabelProperties = 'true' and
                      $hasNoLabelProperties = 'true'" />
      <xsl:when test="$paramValue = $value">
	<a rel="nofollow" title="remove filter">
	  <xsl:attribute name="href">
	    <xsl:call-template name="substituteParam">
	      <xsl:with-param name="uri">
		<xsl:apply-templates select="/result" mode="searchURI" />
	      </xsl:with-param>
	      <xsl:with-param name="param" select="$paramName" />
	      <xsl:with-param name="value" select="''" />
	    </xsl:call-template>
	  </xsl:attribute>
	  <img src="{$activeImageBase}/Back.png" alt="remove filter" />
	</a>
      </xsl:when>
      <xsl:when test="$datatype = 'integer' or $datatype = 'decimal'
                      or $datatype = 'float' or $datatype = 'int' or
                      $datatype = 'date' or $datatype = 'dateTime' or
                      $datatype = 'time'">
	<xsl:variable name="min">
	  <xsl:call-template name="paramValue">
	    <xsl:with-param name="uri">
	      <xsl:apply-templates select="/result" mode="searchURI" />
	    </xsl:with-param>
	    <xsl:with-param name="param" select="concat('min-',
                                                 $paramName)" />
	  </xsl:call-template>
	</xsl:variable>
	<xsl:variable name="max">
	  <xsl:call-template name="paramValue">
	    <xsl:with-param name="uri">
	      <xsl:apply-templates select="/result" mode="searchURI" />
	    </xsl:with-param>
	    <xsl:with-param name="param" select="concat('max-',
                                                 $paramName)" />
	  </xsl:call-template>
	</xsl:variable>
	<xsl:choose>
	  <xsl:when test="$max = $value">
	    <a rel="nofollow" title="remove maximum value filter">
	      <xsl:attribute name="href">
		<xsl:call-template name="substituteParam">
		  <xsl:with-param name="uri">
		    <xsl:apply-templates select="/result" mode="searchURI" />
		  </xsl:with-param>
		  <xsl:with-param name="param" select="concat('max-',
                                                       $paramName)" />
		  <xsl:with-param name="value" select="''" />
		</xsl:call-template>
	      </xsl:attribute>
	      <img src="{$activeImageBase}/Back.png"
                   alt="remove maximum value filter" />
	    </a>
	  </xsl:when>
	  <xsl:otherwise>
	    <a rel="nofollow" title="filter to values equal to or less than {$value}">
	      <xsl:attribute name="href">
		<xsl:call-template name="substituteParam">
		  <xsl:with-param name="uri">
		    <xsl:apply-templates select="/result" mode="searchURI" />
		  </xsl:with-param>
		  <xsl:with-param name="param" select="concat('max-',
                                                       $paramName)" />
		  <xsl:with-param name="value" select="$value" />
		</xsl:call-template>
	      </xsl:attribute>
	      <xsl:choose>
		<xsl:when test="$max != ''">
		  <img src="{$activeImageBase}/Arrow3_Left.png"
                       alt="equal to or less than {$value}" />
		</xsl:when>
		<xsl:otherwise>
		  <img src="{$inactiveImageBase}/Arrow3_Left.png"
                       alt="equal to or less than {$value}" />
		</xsl:otherwise>
	      </xsl:choose>
	    </a>
	  </xsl:otherwise>
	</xsl:choose>
	<xsl:choose>
	  <xsl:when test="$min = $value">
	    <a rel="nofollow" title="remove minimum value filter">
	      <xsl:attribute name="href">
		<xsl:call-template name="substituteParam">
		  <xsl:with-param name="uri">
		    <xsl:apply-templates select="/result"
                                         mode="searchURI" />
		  </xsl:with-param>
		  <xsl:with-param name="param" select="concat('min-',
                                                       $paramName)" />
		  <xsl:with-param name="value" select="''" />
		</xsl:call-template>
	      </xsl:attribute>
	      <img src="{$activeImageBase}/Back.png"
                   alt="remove minimum value filter" />
	    </a>
	  </xsl:when>
	  <xsl:otherwise>
	    <a rel="nofollow" title="filter to values equal to or more than {$value}">
	      <xsl:attribute name="href">
		<xsl:call-template name="substituteParam">
		  <xsl:with-param name="uri">
		    <xsl:apply-templates select="/result"
                                         mode="searchURI" />
		  </xsl:with-param>
		  <xsl:with-param name="param" select="concat('min-',
                                                       $paramName)" />
		  <xsl:with-param name="value" select="$value" />
		</xsl:call-template>
	      </xsl:attribute>
	      <xsl:choose>
		<xsl:when test="$min != ''">
		  <img src="{$activeImageBase}/Arrow3_Right.png"
                       alt="equal to or more than {$value}" />
		</xsl:when>
		<xsl:otherwise>
		  <img src="{$inactiveImageBase}/Arrow3_Right.png"
                       alt="equal to or more than {$value}" />
		</xsl:otherwise>
	      </xsl:choose>
	    </a>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <xsl:otherwise>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Patch 6 -->
  <!-- Fix display of format labels. The link "html"
       did not appear properly, and caused wrapping. -->
  <xsl:template match="hasFormat/item" mode="nav">
    <xsl:variable name="name">
      <xsl:choose>
        <xsl:when test="format">
          <xsl:apply-templates select="." mode="name" />
        </xsl:when>
        <!-- pick the (misplaced) label up from the result if there is one there -->
<!--            <xsl:when test="/result/label"> -->
<!--               <xsl:apply-templates select="/result" mode="name" /> -->
<!--            </xsl:when> -->
           <!-- pick up best label from misplaced result - cann only happen for html-->
           <xsl:otherwise>
             <xsl:text>html</xsl:text>
<!--               <xsl:apply-templates select="/result" mode="name" /> -->
           </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="format">
        <a href="{@href}" type="{format/label}" rel="alternate"
           title="view in {$name} format">
          <xsl:value-of select="label" />
        </a>
      </xsl:when>
      <xsl:when test="/result/format/label and /result/label">
        <a href="{@href}" type="{/result/format/label}" rel="alternate"
           title="view in {$name} format">
<!--                <xsl:value-of select="/result/label" /> -->
          <xsl:value-of select="$name" />
        </a>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- Patch 7 -->
  <!-- The off-the-shelf searchURI template assumes that there is
       a "top-level" list endpoint whose URL can be obtained
       by stripping back the URL of the current page, removing
       everything after the last slash. But that's wrong for
       SISSVoc; for the item endpoint whose URL ends in
       .../resource, we want to switch to the list endpoint
       .../concept.

       So, if the current URL is the _item_ endpoint .../resource,
       replace it with the concept _list_ endpoint .../concept, and
       remove any ?uri=... parameter.

       This template is made simpler than the off-the-shelf version
       that uses the "uriExceptLastPart" template, as we take
       advantage of Saxon's nice fn:replace() function.

       Structure of the template:
       * switch on whether this is a _list_ endpoint.
       * if it is a list endpoint, use the href of the first result.
       * otherwise (it's an _item_ endpoint), start with the href, and
         see if it contains the resourceEndPoint. If so, match on it, as
         well as any extension (e.g., ".html" or ".json") and any
         "uri=..." parameter. Replace the resourceEndPoint with
         conceptSearchEndPoint, and remove any "uri=..." parameter,
         leaving the extension and any other query parameters intact.

       For CC-2370 RVA-294, the last step has been re-implemented in
       two steps:
       * Replace the resourceEndPoint with conceptSearchEndPoint using
         fn:replace.
       * Remove any "uri=..." parameter using the substituteParam
         template.
  -->
  <xsl:param name="conceptSearchEndPoint" />

  <xsl:template match="result" mode="searchURI">
    <xsl:choose>
      <xsl:when test="items">
        <xsl:value-of select="first/@href" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="searchURIoriginal" select="@href" />
        <xsl:variable name="searchURIafterReplace">
          <xsl:choose>
            <xsl:when test="contains($searchURIoriginal, $resourceEndPoint)">
	      <xsl:call-template name="substituteParam">
		<xsl:with-param name="uri">
		  <xsl:value-of select="fn:replace($searchURIoriginal,
                                        concat($resourceEndPoint,'(\.[a-z]+)?'),
                                        concat($conceptSearchEndPoint,'$1'))" />
		</xsl:with-param>
		<xsl:with-param name="param" select="'uri'" />
		<xsl:with-param name="value" select="''" />
	      </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$searchURIoriginal" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="$searchURIafterReplace" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Patch 8 -->
  <!-- _Don't_ use the off-the-shelf ambiguous formatting 06/06/2018,
       but use YYYY-MM-DD.
       _Do_ keep the pretty-printing of replacing the "T" with a space.
       _Don't_ trim the timezone.
  -->
  <xsl:template match="*[@datatype = 'date' or @datatype = 'dateTime' or @datatype = 'time']" mode="display">
    <time datetime="{.}">
      <xsl:choose>
        <xsl:when test="@datatype = 'date' or @datatype = 'dateTime'">
          <xsl:value-of select="substring(., 1, 10)" />
          <xsl:if test="@datatype = 'dateTime'">
            <xsl:text> </xsl:text>
            <xsl:value-of select="substring(substring-after(., 'T'), 1)" />
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="." mode="content" />
        </xsl:otherwise>
      </xsl:choose>
    </time>
  </xsl:template>

  <!-- Patch 9 -->
  <!-- There is already percent-escaping of hashes in IRIs;
       also do percent-escaping of ampersands.
  -->
  <xsl:template match="@href" mode="adjust-uri">
    <xsl:variable name="p1">
      <xsl:call-template name="string-replace-all">
	<xsl:with-param name="text" select="." />
	<xsl:with-param name="replace" select="string('#')" />
	<xsl:with-param name="by" select="string('%23')" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="p2">
      <xsl:call-template name="string-replace-all">
	<xsl:with-param name="text" select="$p1" />
	<xsl:with-param name="replace" select="string('&amp;')" />
	<xsl:with-param name="by" select="string('%26')" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="adjustedHref" select="concat($resourcePath,'?uri=', $p2)"/>
    <xsl:value-of select="$adjustedHref" />
  </xsl:template>

  <!-- Patch 10 -->
  <!-- Honour newlines within string data.  First, remove all leading
       and trailing whitespace. Then, replace all newlines with br
       elements. Code to do the latter is based on an example in: Jeni
       Tennison, "Beginning XSLT 2.0: From Novice to Professional",
       2005, pp. 208-209.
       Line-break regular expression enhanced to support multiple types of
       line ending: just CR, just LF, and CRLF.
       NB: we previously imported the original template for this
       match/mode combination above. (See just before the comment
       "End of verbatim-copied templates.")
  -->
  <xsl:template match="*" mode="content">
    <xsl:variable name="trimmed">
      <xsl:value-of select="replace(., '^\s+|\s+$', '')" />
    </xsl:variable>
    <xsl:analyze-string select="$trimmed" regex="\r\n|\r|\n">
      <xsl:matching-substring>
	<br />
      </xsl:matching-substring>
      <xsl:non-matching-substring>
	<xsl:value-of select="." />
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>

  <!-- Patch 11 -->
  <!-- CC-2091 CC-2609 Add CSIRO credit to footer.
       And while we're here, add ARDC logo.
       And while we're here, update Axialis credit to what they now
       ask for.
  -->
  <xsl:template match="result" mode="footer">
    <footer>
      <xsl:apply-templates select="wasResultOf" mode="footer" />
      <div class="clearfix" style="margin-top: 20px">
	<div class="pull-right">
	  <div style="display: inline-block; vertical-align: top; margin-right: 50px; margin-bottom: 20px">
	    <img src="{$myResourceImagesBase}/csiro-brandmark-resized.png" alt="CSIRO brandkmark" /><br />
	    <br />
	    SISSVoc was developed by
	    <a target="_blank" href="https://www.csiro.au/">CSIRO</a>.<br />
	    <xsl:text>Powered by </xsl:text>
	    <xsl:apply-templates select="wasResultOf/processor" mode="footer" />
	    <xsl:text>an implementation of the </xsl:text>
	    <a href="http://code.google.com/p/linked-data-api">Linked Data API</a>.<br />
	    <a href="http://www.axialis.com/free/icons/">Icons</a> by <a href="http://www.axialis.com">Axialis</a>.<br />
	    <span id="rewrite_onsite">Double-click HERE to stay onsite.</span>
	  </div>
	  <div style="display: inline-block; vertical-align: top; margin-right: 30px">
	    <img src="{$myResourceImagesBase}/ardc_logo.svg" style="height: 70px" alt="ARDC logo" /><br />
	    <br />
	    This installation is operated and maintained<br />
	    by the
	    <a target="_blank" href="https://ardc.edu.au">Australian Research Data Commons</a>.<br />
	    Contact <a href="mailto:{$serviceAuthorEmail}"><xsl:value-of select="$serviceAuthor"/></a>.<br/>
	  </div>
	</div>
      </div>

      <xsl:comment><xsl:value-of select='$configID'/></xsl:comment>

    </footer>
  </xsl:template>

  <!-- Patch 12 -->
  <!-- Change font. Import Roboto.
  -->
  <xsl:template match="result" mode="style">
    <link href='//fonts.googleapis.com/css?family=Roboto:200,300,400,600,700,900,300italic,400italic,600italic' rel='stylesheet' type='text/css' />
    <link rel="stylesheet" href="{$_resourceRoot}css/html5reset-1.6.1.css" type="text/css" />
    <link rel="stylesheet" href="{$SISSDefaultResourceDirBase}css/jquery-ui.css" type="text/css" />
    <link rel="stylesheet" href="{$_resourceRoot}css/result.css" type="text/css" />
    <link rel="stylesheet" href="{$SISSDefaultResourceDirBase}css/sissstyle.css" type="text/css" />
    <link rel="stylesheet" href="{$myResourceCSSResultFile}" type="text/css" />
    <xsl:comment>
      <xsl:text>[if lt IE 9]&gt;</xsl:text>
      <xsl:text>&lt;link rel="stylesheet" href="</xsl:text><xsl:value-of select='$_resourceRoot'/><xsl:text>css/ie.css" type="text/css">&lt;/link></xsl:text>
      <xsl:text>&lt;script src="http://ie7-js.googlecode.com/svn/version/2.1(beta4)/IE9.js">&lt;/script></xsl:text>
      <xsl:text>&lt;![endif]</xsl:text>
    </xsl:comment>
</xsl:template>

  <!-- Patch 13 -->
  <!-- Restructure div id="page" to come after the top header.
       Move the formats to below the vocabulary title.
  -->
  <xsl:template match="result">
    <html>
      <head>
        <xsl:apply-templates select="." mode="title" />
        <xsl:apply-templates select="." mode="meta" />
        <xsl:apply-templates select="." mode="script" />
        <xsl:apply-templates select="." mode="style" />
      </head>
      <body>
        <xsl:apply-templates select="." mode="header" />
	<div id="page-border">
          <div id="page">

	    <xsl:if test="$_ANDS_vocabMore != ''"
		    ><p><a href="{$_ANDS_vocabMore}"
			   target="_blank"><i>(more information)</i></a></p></xsl:if>
	    <xsl:if test="$_ANDS_vocabAPIDoco != ''"
		    ><p><a href="{$_ANDS_vocabAPIDoco}"
			   target="_blank"><i>(web service API)</i></a></p></xsl:if>

	    <nav class="formats">
	      <xsl:apply-templates select="." mode="formats" />
	    </nav>

            <xsl:apply-templates select="." mode="content" />
          </div>
	</div>
        <xsl:apply-templates select="." mode="footer" />
      </body>
    </html>
  </xsl:template>

  <!-- Patch 14 -->
  <!-- CC-2369 RVA-292 Since recent jQuery toggle() doesn't do what it
       used to, replace its uses with a new function.  Function
       definition sourced from
       https://forum.jquery.com/portal/en/community/topic/beginner-function-toggle-deprecated-what-to-use-instead
       and https://jsfiddle.net/s376u4zn/1/ .
  -->
  <xsl:template match="result" mode="script">
    <script type="text/javascript" src="{$SISSDefaultResourceDirBase}js/jquery.min.js"></script>
    <script type="text/javascript" src="{$SISSDefaultResourceDirBase}js/jquery-ui.min.js"></script>
    <script type="text/javascript" src="{$_resourceRoot}scripts/codemirror/codemirror_min.js"></script>

    <script type="text/javascript">
      <![CDATA[
	$(document).ready(function() {
	    var AlreadyRun = false;
		$("#rewrite_onsite").dblclick(function() {
			var hostPattern = /(^https?:\/\/[^\/]*)/
			var url = document.URL;

			if (AlreadyRun != true) {
			    AlreadyRun = true;
				$("a[class=outlink]").each( function(a) {
				  var replacement = /.*[?&=#].*/.test(this.href) ? encodeURIComponent(this.href) : encodeURI(this.href);]]>
				  this.href = this.href.replace(this.href,'<xsl:value-of select="$resourceEndPoint"/>'+"?uri="+replacement);
				});
				alert("OutLinks have been rewritten internal to the VOCAB!");
			}
			else {
				alert("OutLinks have ALREADY been rewritten!");
			}
		});
	});
    </script>

    <script type="text/javascript">
		$(function() {
			$.fn.toggleLegacy = function () {
				var functions = arguments
				return this.each(function () {
					var iteration = 0;
					$(this).click(function () {
						functions[iteration].apply(this, arguments);
						iteration = (iteration + 1) % functions.length;
					});
				});
			};

			$('.info img')
				.toggleLegacy(function () {
					$(this)
						.attr('src', '<xsl:value-of select="$activeImageBase"/>/Cancel.png')
						.next().show();
				}, function () {
					$(this)
						.attr('src', '<xsl:value-of select="$activeImageBase"/>/Question.png')
						.next().fadeOut('slow');
				});

			$('.provenance textarea')
				.each(function () {
					var skipLines = parseFloat($(this).attr('data-skip-lines'), 10);
					var lineHeight = parseFloat($(this).css('line-height'), 10);
					$(this).scrollTop(skipLines * lineHeight);
					var cm = CodeMirror.fromTextArea(this, {
						basefiles: ["<xsl:value-of select='$_resourceRoot'/>scripts/codemirror/codemirror_base_sparql.js"],
						stylesheet: "<xsl:value-of select='$_resourceRoot'/>css/sparql.css",
						textWrapping: false
					});
					$(cm.frame).load(function () {
						cm.jumpToLine(skipLines + 1);
						$(cm.frame)
							.css('border', 	'1px solid #D3D3D3')
							.css('border-radius', '5px')
							.css('-moz-border-radius', '5px');
					});
				});
		});
    </script>
  </xsl:template>
  <!-- CC-2369 RVA-292 Follow-on from the previous template: now that
       the help buttons are visible, if you click the one for "Sort
       by", the help text is long, and can extend over the following
       "View" box. Without this patch, together with the override in
       mystyle.css, the question mark icon of the "View" box would
       stick through the popup.
  -->
  <xsl:template name="createInfo">
    <xsl:param name="text" />
    <div class="info">
      <img class="open" src="{$activeImageBase}/Question.png" alt="help" />
      <p class="ui-tooltip"><xsl:copy-of select="$text" /></p>
    </div>
  </xsl:template>

  <!-- Patch 15 -->
  <!-- CC-2368 RVA-293 Don't break the sort panel after removing one
       of the existing sort fields.
  -->
  <xsl:template match="result" mode="selectedSorts">
    <xsl:param name="uri" />
    <xsl:param name="sorts" />
    <xsl:param name="previousSorts" select="''" />
    <xsl:variable name="sort" select="substring-before(concat($sorts, ','), ',')" />
    <xsl:variable name="paramName">
      <xsl:choose>
	<xsl:when test="starts-with($sort, '-')">
	  <xsl:value-of select="substring($sort, 2)" />
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$sort" />
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="isLabelParam">
      <xsl:call-template name="isLabelParam">
	<xsl:with-param name="paramName" select="$paramName" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="sortsAfterComma">
      <xsl:value-of select="substring-after($sorts, ',')" />
    </xsl:variable>
    <li class="selected">
      <a rel="nofollow" title="remove this sort">
	<xsl:attribute name="href">
	  <xsl:call-template name="substituteParam">
	    <xsl:with-param name="uri" select="$uri" />
	    <xsl:with-param name="param" select="'_sort'" />
	    <xsl:with-param name="value">
	      <xsl:if test="$previousSorts != ''">
		<xsl:value-of select="$previousSorts" />
		<xsl:if test="$sortsAfterComma != ''">
		  <xsl:text>,</xsl:text>
		</xsl:if>
	      </xsl:if>
	      <xsl:value-of select="$sortsAfterComma" />
	    </xsl:with-param>
	  </xsl:call-template>
	</xsl:attribute>
	<img src="{$activeImageBase}/Cancel.png" alt="remove this sort" />
      </a>
      <a rel="nofollow">
	<xsl:attribute name="href">
	  <xsl:call-template name="substituteParam">
	    <xsl:with-param name="uri" select="$uri" />
	    <xsl:with-param name="param" select="'_sort'" />
	    <xsl:with-param name="value">
	      <xsl:if test="$previousSorts != ''">
		<xsl:value-of select="$previousSorts" />
		<xsl:text>,</xsl:text>
	      </xsl:if>
	      <xsl:choose>
		<xsl:when test="starts-with($sort, '-')">
		  <xsl:value-of select="substring($sort, 2)" />
		</xsl:when>
		<xsl:otherwise>
		  <xsl:value-of select="concat('-', $sort)" />
		</xsl:otherwise>
	      </xsl:choose>
	    </xsl:with-param>
	  </xsl:call-template>
	</xsl:attribute>
	<xsl:attribute name="title">
	  <xsl:choose>
	    <xsl:when test="starts-with($sort, '-')">sort in ascending order</xsl:when>
	    <xsl:otherwise>sort in descending order</xsl:otherwise>
	  </xsl:choose>
	</xsl:attribute>
	<xsl:choose>
	  <xsl:when test="starts-with($sort, '-')">
	    <img src="{$activeImageBase}/Arrow3_Down.png" alt="sort in ascending order" />
	  </xsl:when>
	  <xsl:otherwise>
	    <img src="{$activeImageBase}/Arrow3_Up.png" alt="sort in descending order" />
	  </xsl:otherwise>
	</xsl:choose>
      </a>
      <xsl:text> </xsl:text>
      <xsl:choose>
	<xsl:when test="$isLabelParam = 'true'">
	  <xsl:value-of select="$paramName" />
	</xsl:when>
	<xsl:otherwise>
	  <xsl:call-template name="splitPath">
	    <xsl:with-param name="paramName" select="$paramName" />
	  </xsl:call-template>
	</xsl:otherwise>
      </xsl:choose>
    </li>
    <xsl:if test="contains($sorts, ',')">
      <xsl:variable name="nextPreviousSorts">
	<xsl:choose>
	  <xsl:when test="$previousSorts = ''">
	    <xsl:value-of select="$sort" />
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:choose>
	      <xsl:when test="$sort = ''">
		<xsl:value-of select="$previousSorts" />
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:value-of select="concat($previousSorts, ',', $sort)" />
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:variable>
      <xsl:apply-templates select="." mode="selectedSorts">
	<xsl:with-param name="uri" select="$uri" />
	<xsl:with-param name="sorts" select="substring-after($sorts, ',')" />
	<xsl:with-param name="previousSorts" select="$nextPreviousSorts" />
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
