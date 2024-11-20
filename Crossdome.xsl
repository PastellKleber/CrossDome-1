<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">

    <xsl:output encoding="UTF-8" indent="yes" method="html" standalone="yes" xml:space="default"/>
    
    <xsl:include href="htmlTemplates.xsl"/>

	<xsl:template match='/'>
		<xsl:result-document byte-order-mark="yes"
			href="crossdome_1.html">
		<html>
			<head>
				<title>
					<xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/title[1]"/>
				</title>
				<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
				<link href="c64colors.css" rel="stylesheet" type="text/css"/>
				<link href="c64fonts.css" rel="stylesheet" type="text/css"/>
				<link href="crossdome.css" rel="stylesheet" type="text/css"/>				
			</head>
			
			<body>
				<xsl:apply-templates select="TEI/text/front"/>
				<xsl:apply-templates select="TEI/text/body"/>
				<xsl:apply-templates select="TEI/text/back"/>
			</body>
		</html>
		</xsl:result-document>
	</xsl:template>

<!-- Lexikon implementieren -->
	
	<xsl:template match="TEI//g">
		<!-- Referenz-ID -->
		<xsl:variable name="refId" select="substring(@ref, 2)" />
		
		<!-- passende Glyphe im charDecl -->
		<xsl:variable name="Unicode" select="id($refId)/mapping[@type='unicode']/text()" />
		<xsl:variable name="Graphic" select="id($refId)/figure/graphic/@url" />
		
		
		<!-- Wenn Unicode-Mapping, verwenden -->
		<xsl:choose>
			
			<!-- Wenn Bild gibt, verwenden -->
			<xsl:when test="$Graphic">
				<span class="glyphgr">
					<img src="zeichen/{$Graphic}" alt="{id($refId)/desc}" title="{id($refId)/desc}" />
				</span>
			</xsl:when>
			
			<xsl:when test="$Unicode">
				<span class="glyph" title="{id($refId)/desc}">
					<xsl:value-of select="$Unicode"/> 
				</span>
			</xsl:when>	
			
			<!-- Andernfalls Element ohne Transformation ausgeben -->
			<xsl:otherwise>
				<span data-tei="g" title="{@ref}">
					<xsl:apply-templates/>
				</span>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>	

	<!-- TEI figure -->
	<xsl:template match="TEI/text//figure">
		<!-- container for images and caption -->
		<figure data-tei="figure">
			<xsl:apply-templates/>
		</figure>
	</xsl:template>
	
	<!-- TEI graphic -->
	<xsl:template match="TEI/text//figure/graphic">
		<img alt="{../desc/text()}" data-tei="graphic" src="images/{@url}"/>
	</xsl:template>
    
    <xsl:template match="TEI/text//ab[@type='boxDrawing']">
        <span class="{@rend}" data-tei="ab">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="TEI/text//graphic">
        <img class="{graphic}" data-tei="graphic" src="../images/{@src}" title="Abbildung: {@title}"/>
    </xsl:template>
    
    <xsl:template match="TEI/text//hi">
        <xsl:choose>
            <xsl:when test="contains(@rend, 'widespace')">
                <!-- Sonderbehandlung von Sperrungen -->
                <xsl:variable name="charBefore"
                    select="substring(preceding-sibling::text()[1], string-length(preceding-sibling::text()[1]))"/>
                <xsl:variable name="charAfter"
                    select="substring(following-sibling::text()[1], 1, 1)"/>
                <span data-tei="hi">
                    <xsl:attribute name="class">
                        <xsl:value-of select="@rend"/>
                        <xsl:text> </xsl:text>
                        <!-- widespaceBefore bei vorausgehendem Spatium -->
                        <xsl:if test="contains(' ', $charBefore)">
                            <xsl:text> widespaceBefore</xsl:text>
                        </xsl:if>
                        <!-- noWidespaceAfter bei anschließenden (kleinen) Satzzeichen -->
                        <xsl:if test="contains(',.“', $charAfter)">
                            <xsl:text> noWidespaceAfter</xsl:text>
                        </xsl:if>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <span class="{@rend}" data-tei="hi">
                    <xsl:apply-templates/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <!-- editorial elements -->
    
    <xsl:template match="TEI/text//choice">
        <span class="editorial choice">[</span>
        <xsl:apply-templates select="orig | sic"/>
        <span class="editorial choice">|</span>
        <xsl:apply-templates select="reg | corr"/>
        <span class="editorial choice">]</span>
    </xsl:template>
    
    <xsl:template match="TEI/text//choice/text()"/>
    
    <xsl:template match="TEI/text/body//choice/sic">
        <span title="editorial sic">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="TEI/text//choice/corr">
        <span class="editorial corr" title="corr">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="TEI/text//gap">
        <span class="editorial gap" title="Auslassung">
            <xsl:text>…</xsl:text>
        </span>
    </xsl:template>
    
    <xsl:template match="TEI/text//surplus">
        <span class="surplus" title="überflüssiger Text">
            <span class="editorial">[</span>
            <xsl:apply-templates/>
            <span class="editorial">]</span>
        </span>
    </xsl:template>
    
    <xsl:template match="TEI/text//supplied">
        <span class="editorial supplied" title="fehlender Text">
            <xsl:text>[</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>]</xsl:text>
        </span>
    </xsl:template>       
    
    <!-- semantic elements -->
    
    <xsl:template match="TEI/text//date">
        <a class="{string-join(('date',@rend),' ')}" title="Datum">
            <xsl:apply-templates/>
        </a>
    </xsl:template>
    
    <xsl:template match="TEI/text//rs[@type = 'event']">
        <span class="semantic rs" title="Aufführung">
            <a class="event" href="{concat('event?id=', @ref)}">
                <!-- HALFWIDTH LEFT CORNER BRACKET (U+FF62) -->
                <xsl:text>｢</xsl:text>
            </a>
            <xsl:apply-templates/>
            <a class="event" href="{concat('event?id=', @ref)}">
                <!-- HALFWIDTH RIGHT CORNER BRACKET (U+FF63) -->
                <xsl:text>｣</xsl:text>
            </a>
        </span>
    </xsl:template>
    
    <xsl:template match="TEI/text//persName">
        <a data-tei="persName" title="Person">
            <xsl:attribute name="href" select="concat('person?id=', @ref)"/>
            <xsl:apply-templates/>
        </a>
    </xsl:template>
    
    <xsl:template match="TEI/text//placeName">
        <a data-tei="placeName" title="Ort">
            <xsl:attribute name="href" select="concat('place?id=', @ref)"/>
            <xsl:apply-templates/>
        </a>
    </xsl:template>
    
    <xsl:template match="TEI/text//title">
        <a class="semantic title" title="Werk der Musik">
            <xsl:attribute name="href" select="concat('title?id=', @ref)"/>
            <xsl:apply-templates/>
        </a>
    </xsl:template>
    
    <xsl:template match="TEI/text//orgName">
        <a class="semantic orgName" title="Ort">
            <xsl:attribute name="href" select="concat('org?id=', @ref)"/>
            <xsl:apply-templates/>
        </a>
    </xsl:template>
    
    <!-- bibliographic elements -->
    
    <xsl:template match="sourceDesc/bibl">
        <xsl:apply-templates/>
        <xsl:text>.</xsl:text>
    </xsl:template>
    
    <xsl:template match="sourceDesc//orgName[@role = 'publisher']">
        <xsl:value-of select="@ref"/>
    </xsl:template>
    
    <xsl:template match="sourceDesc//placeName">
        <xsl:text>(</xsl:text>
        <xsl:value-of select="@ref"/>
        <xsl:text>)</xsl:text>
    </xsl:template>
    
    <xsl:template match="sourceDesc//date[@when-iso]">
        <xsl:value-of select="@when-iso"/>
    </xsl:template>
    
    <xsl:template match="sourceDesc//series">
        <xsl:value-of select="."/>
    </xsl:template>

	<!-- CONCEPTIONAL ITEMS, division layer -->

	<!-- TEI front -->
	<xsl:template match="TEI/text/front">
		<!-- HTML-Seitenkopf -->
		<header data-tei="front">
			<xsl:apply-templates/>
		</header>
	</xsl:template>
	

	<!-- TEI body -->
	<xsl:template match="TEI/text/body">
		<!-- HTML-Seitentext -->
		<article data-tei="body">
			<xsl:apply-templates/>
		</article>
	</xsl:template>

	<!-- TEI back -->
	<xsl:template match="TEI/text/back">
		<!-- HTML-Seitenfuß -->
		<footer data-tei="back">
			<xsl:apply-templates/>
			<!-- noch: Quellenangaben -->
			<!-- noch: Zitationsvorschlag -->
			<!-- noch: Lizenz -->
		</footer>
	</xsl:template>

	<!-- TEI division -->
	<xsl:template match="TEI/text//div">
		<div class="div{count(ancestor::div)+1}" data-tei="div">
			<xsl:apply-templates select="@xml:id | node()"/>
		</div>
	</xsl:template>

	<!-- TEI division ids -->
	<xsl:template match="TEI/text//div/@xml:id">
		<xsl:attribute name="id" select="."/>
	</xsl:template>


	<!-- CONCEPTIONAL ITEMS, block layer -->

	<!-- TEI header -->
	<xsl:template match="TEI/text//head[@type]">
		<!-- type can be h1 or h2 -->
		<!-- TODO: check this by Schematron -->
		
		<xsl:element name="{@type}">
			<xsl:attribute name="data-tei" select="'head'"/>
			<xsl:apply-templates select="@rend | node()"/>			
		</xsl:element>
		<img src="{id(substring(@facs,2))/@url}"/>				
	</xsl:template>

	<!-- TEI header -->
	<xsl:template match="TEI/text//head[not(@type)]">
		<!-- heading without type becomes h3 -->
		<h3 data-tei="head">
			<xsl:apply-templates select="@rend | node()"/>
		</h3>
	</xsl:template>

	<!-- TEI paragraph -->
	<xsl:template match="TEI/text//p">
		<p data-tei="p">
			<xsl:apply-templates select="@rend | node()"/>
		</p>
	</xsl:template>

	<!-- TEI anonymous block -->

	<xsl:template match="TEI/text//ab">
		<p data-tei="ab">
			<xsl:apply-templates select="@rend | node()"/>
		</p>
	</xsl:template>

	<!-- TEI forme work -->
	<xsl:template match="TEI/text//fw"/>

<!-- graphic -->

	<!-- TEI desc -->
	<!-- just in case -->
	<xsl:template match="TEI/text//figure/desc">
		<figcaption data-tei="desc">
			<xsl:apply-templates/>
		</figcaption>
	</xsl:template>

	<!-- TEI span -->
	<xsl:template match="TEI/text//span">
		<span data-tei="span">
			<xsl:apply-templates select="@rend | node()"/>
		</span>
	</xsl:template>

	<!-- TEI rendition -->
	<xsl:template match="TEI/text//@rend">
		<!-- insert rend directly into css class -->
		<xsl:attribute name="class" select="."/>
	</xsl:template>

	<!-- TEI reference -->
	<xsl:template match="TEI/text//ref[@target]">
		<!-- create hyperlink -->
		<a data-tei="ref" href="{@target}">
			<xsl:if test="substring(@target, 1, 4) = 'http'">
				<xsl:attribute name="target" select="'_blank'"/>
				<xsl:text>↗</xsl:text>
			</xsl:if>
			<xsl:apply-templates/>
		</a>
	</xsl:template>


	<!-- TOPOGRAPHIC ITEMS, generic -->

	<!-- TEI page beginning, in paragraph -->
	<xsl:template match="TEI/text//p//pb">
		<!-- insert a space if first lb on page is 'word breaking' -->
		<xsl:if test="following::lb[1]/@break = 'yes' or not(following::lb[1]/@break)">
			<xsl:text></xsl:text>
		</xsl:if>
		<!-- insert a mark for the pb -->
		<span class="editorialMark" data-tei="pb">
			<xsl:text>|</xsl:text>
			<!-- insert page number to appear in the margin -->
			<span class="leftMargin" data-tei="@n">
				<xsl:value-of select="@n"/>
			</span>
		</span>
	</xsl:template>

	<!-- TEI line beginning, in preserveSpace environment -->
	<!-- prioritized over generic lb -->
	<xsl:template match="TEI/text//p//lb" priority="+1">
		<!-- put line break, except for first lb -->
		<xsl:if test="current() >> ancestor::p/lb[1]">
			<br/>
		</xsl:if>
	</xsl:template>

	<!-- TEI line beginning, inside of preformatted environment -->
	<!-- prioritized over generic lb -->
	<xsl:template match="TEI/text//ab//lb" priority="+1">
		<!-- put line break, except for first lb -->
		<xsl:if test="current() >> ancestor::ab/lb[1]">
			<br/>
		</xsl:if>
	</xsl:template>

	<!-- TEI span, horizontal ruler as box drawing -->
	<!-- prioritized over generic span -->
	<xsl:template match="span[@ana = '#hr']" priority="+1"/>

	<!-- TEI span, underlining as box drawing -->
	<!-- prioritized over newline template (no \n to be expected here) -->
	<xsl:template match="span[@ana = '#u']/text()" priority="+1">
		<!-- put spaces instead of underline box characters -->
		<xsl:for-each select="1 to string-length(.)">
			<xsl:text> </xsl:text>
		</xsl:for-each>
	</xsl:template>

	<!-- TEI space -->
	<xsl:template match="TEI/text//space[@dim = 'vertical']"/>

	<!-- TEI surplus -->
	<xsl:template match="TEI/text//surplus">
		<span data-tei="surplus" title="surplus text">
			<!-- editorial mark before -->
			<span class="editorialMark">[</span>
			<!-- original text outside of spans -->
			<xsl:apply-templates/>
			<!-- editorial mark after -->
			<span class="editorialMark">]</span>
		</span>
	</xsl:template>

	<!-- TEI supplied -->
	<xsl:template match="TEI/text//supplied">
		<span data-tei="supplied" title="supplied text">
			<span class="editorialText">
				<!-- supplied text inside of span -->
				<xsl:apply-templates/>
			</span>
		</span>
	</xsl:template>

	<!-- TEI term -->
	<xsl:template match="TEI/text//term[@target]">
		<!-- insert a mark in the right margin -->
		<span class="editorialMark rightMargin">
			<!-- teardrop-spoked asterisk -->
			<xsl:text>✻</xsl:text>
		</span>
		<span class="term" data-tei="term">
			<xsl:apply-templates/>
			<xsl:apply-templates mode="note" select="id(substring(@target, 2))"/>
		</span>
	</xsl:template>

	<!-- parse only in "note" mode -->
	<xsl:template match="TEI/text//note" mode="note">
		<span class="note" data-tei="note">
			<xsl:apply-templates/>
			<xsl:apply-templates select="@resp"/>
			<img src="{id(substring(@facs,2))/@url}"/>
		</span>
	</xsl:template>

	<xsl:template match="TEI/text//note/@resp">
		<xsl:text> </xsl:text>
		<i data-tei="@resp">
			<xsl:value-of select="."/>
		</i>
	</xsl:template>


	<!-- SEMANTIC ITEMS -->

	<!-- TEI code -->
	<!-- presented inline -->
	<xsl:template match="TEI/text//code">
		<span class="code" data-tei="code" title="code">
			<xsl:apply-templates/>
		</span>
	</xsl:template>
	
	<!-- TEI lang -->
	<!-- presented inline -->
	<xsl:template match="TEI/text//lang">
		<span class="code" data-tei="code" title="code">
			<xsl:apply-templates/>
		</span>
	</xsl:template>
	
	<!-- presented as a text block, but semantically within a paragraph -->
	<xsl:template match="TEI/text//code[@rend = 'block']" priority="+1">
		<span class="code block" data-tei="code" title="code">
			<xsl:apply-templates/>
		</span>
	</xsl:template>

	<!-- TEI name -->
	<xsl:template match="TEI/text//name">
		<a data-tei="name" title="name">
			<xsl:apply-templates/>
		</a>
	</xsl:template>

	<!-- TEI organization name -->
	<xsl:template match="TEI/text//orgName">
		<a data-tei="orgName" title="orgName">
			<xsl:apply-templates/>
		</a>
	</xsl:template>

	<!-- TEI person name -->
	<xsl:template match="TEI/text//persName">
		<a data-tei="persName" title="persName">
			<xsl:apply-templates/>
		</a>
	</xsl:template>

	<!-- TEI title -->
	<xsl:template match="TEI/text//title">
		<a data-tei="title" title="title">
			<xsl:apply-templates/>
		</a>
	</xsl:template>


	<!-- LISTS -->

	<xsl:template match="TEI/text//list[@type] | listPerson | listBibl[@type] | listOrg">
		<ul>
			<xsl:apply-templates mode="list"/>
		</ul>
	</xsl:template>

	<xsl:template match="TEI/text//(list[@type] | listBibl[@type] | listOrg | listPerson)/head"
		mode="list" priority="+1">
		<h3>
			<xsl:apply-templates mode="list"/>
		</h3>
	</xsl:template>

	<xsl:template match="TEI/text//(list[@type] | listBibl[@type] | listOrg | listPerson)/*"
		mode="list">
		<li>
			<b>
				<xsl:apply-templates select="(name | title | orgName | persName)[1]"/>
			</b>
			<xsl:for-each select="(name | title | orgName | persName)[position() > 1]">
				<xsl:text>, </xsl:text>
				<xsl:apply-templates/>
			</xsl:for-each>
			<xsl:for-each select="desc | note">
				<xsl:text>, </xsl:text>
				<xsl:apply-templates/>
			</xsl:for-each>
			<xsl:for-each
				select="document('../tei/X-Dome_#1_20.11.24.xml')//*[substring(@ref, 2) = current()/@xml:id]">
				<xsl:text> </xsl:text>
				<a>
					<xsl:value-of select="substring(preceding::pb[1]/@xml:id, 3)"/>
				</a>
			</xsl:for-each>
		</li>
	</xsl:template>

	<xsl:template match="TEI/text//listBibl[not(@type)]">
		<ul class="bibliography">
			<xsl:apply-templates/>
		</ul>
	</xsl:template>

	<xsl:template match="TEI/text//listBibl[not(@type)]/bibl">
		<li>
			<xsl:apply-templates/>
		</li>
	</xsl:template>

	<!-- WHITESPACE -->

	<!-- whitespace in newline -->
	<!-- do not render -->
	<xsl:template match="TEI/text//text()">
		<xsl:analyze-string regex="\n" select=".">
			<xsl:matching-substring/>
			<xsl:non-matching-substring>
				<xsl:value-of select="."/>
			</xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:template>

	<xsl:template match="TEI/text//ab[@type='boxDrawing']">
		<span class="{@rend}" data-tei="ab">
			<xsl:apply-templates/>
		</span>
	</xsl:template>
	
	<xsl:template match="TEI/text//graphic">
		<img class="{graphic}" data-tei="graphic" src="../images/{@src}" title="Abbildung: {@title}"/>
	</xsl:template>
		
	<!-- editorial elements -->
	
	<xsl:template match="TEI/text//choice">
		<span class="editorial choice">[</span>
		<xsl:apply-templates select="orig | sic"/>
		<span class="editorial choice">|</span>
		<xsl:apply-templates select="reg | corr"/>
		<span class="editorial choice">]</span>
	</xsl:template>
	
	<xsl:template match="TEI/text//choice/text()"/>
	
	<xsl:template match="TEI/text/body//choice/sic">
		<span title="editorial sic">
			<xsl:apply-templates/>
		</span>
	</xsl:template>
	
	<xsl:template match="TEI/text//choice/corr">
		<span class="editorial corr" title="corr">
			<xsl:apply-templates/>
		</span>
	</xsl:template>
	
	<xsl:template match="TEI/text//gap">
		<span class="editorial gap" title="Auslassung">
			<xsl:text>…</xsl:text>
		</span>
	</xsl:template>
	
	<xsl:template match="TEI/text//surplus">
		<span class="surplus" title="überflüssiger Text">
			<span class="editorial">[</span>
			<xsl:apply-templates/>
			<span class="editorial">]</span>
		</span>
	</xsl:template>
	
	<xsl:template match="TEI/text//supplied">
		<span class="editorial supplied" title="fehlender Text">
			<xsl:text>[</xsl:text>
			<xsl:apply-templates/>
			<xsl:text>]</xsl:text>
		</span>
	</xsl:template>
	
	<xsl:template match="TEI/text//pb | TEI/text//cb">
		
		<xsl:variable as="element()" name="type">
			<xsl:choose>
				<xsl:when test="name() = 'pb'">
					<foo symbol="" type="Seite"/>
				</xsl:when>
				<xsl:when test="name() = 'cb'">
					<foo symbol="" type="Spalte"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<span class="editorial fontReset {name(.)}" title="{$type/@type}nanfang">
			<xsl:if test="@type = 'skipped'">
				<xsl:text>… </xsl:text>
			</xsl:if>
			<xsl:if test="@break = 'no'">
				<xsl:text>-</xsl:text>
			</xsl:if>
			
			<xsl:value-of select="$type/@symbol"/>
			<xsl:choose>
				<xsl:when test="@facs">
					 <a href="{id(substring(@facs,2))/@url}">
<!--						<xsl:apply-templates select="@n"/>-->
					</a>
				</xsl:when>
<!--				<xsl:otherwise>
<!-\-					<xsl:apply-templates select="@n"/>-\->
				</xsl:otherwise>-->
			</xsl:choose>
			<xsl:value-of select="$type/@symbol"/>
			<xsl:if test="not(@break) or @break = 'yes'">
				<xsl:text> </xsl:text>
			</xsl:if>
			<xsl:if test="@type = 'skipped'">
				<xsl:text> …</xsl:text>
			</xsl:if>
		</span>		
		<img src="{id(substring(@facs,2))/@url}"/>
	</xsl:template>
	
	<!-- Zeilenumbruch mit Wortunterbrechung -->
	<!-- default -->
	<xsl:template match="TEI/text//lb[not(@break)]">
		<xsl:text> </xsl:text>
	</xsl:template>
	
	<!-- Zeilenumbrüche überall rausfiltern -->
	<xsl:template match="text()">
		<xsl:analyze-string select="." regex="\n">
			<xsl:matching-substring/>
			<xsl:non-matching-substring>
				<xsl:value-of select="."/>
			</xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:template>
	
	<xsl:template match="TEI/text//note">
		<span class="note">
			<sup class="noteAnchor">
				<xsl:number level="any"/>
			</sup>
			<span class="noteContent">
				<span class="noteContentAnchor">
					<xsl:number level="any"/>)</span>
				<span class="noteContentText">
					<xsl:apply-templates/>
				</span>
			</span>
		</span>
	</xsl:template>	
	
	<!-- semantic elements -->
	
	<xsl:template match="TEI/text//date">
		<a class="{string-join(('date',@rend),' ')}" title="Datum">
			<xsl:apply-templates/>
		</a>
	</xsl:template>
	
	<xsl:template match="TEI/text//rs[@type = 'event']">
		<span class="semantic rs" title="Aufführung">
			<a class="event" href="{concat('event?id=', @ref)}">
				<!-- HALFWIDTH LEFT CORNER BRACKET (U+FF62) -->
				<xsl:text>｢</xsl:text>
			</a>
			<xsl:apply-templates/>
			<a class="event" href="{concat('event?id=', @ref)}">
				<!-- HALFWIDTH RIGHT CORNER BRACKET (U+FF63) -->
				<xsl:text>｣</xsl:text>
			</a>
		</span>
	</xsl:template>
	
	<xsl:template match="TEI/text//persName">
		<a data-tei="persName" title="Person">
			<xsl:attribute name="href" select="concat('person?id=', @ref)"/>
			<xsl:apply-templates/>
		</a>
	</xsl:template>
	
	<xsl:template match="TEI/text//placeName">
		<a data-tei="placeName" title="Ort">
			<xsl:attribute name="href" select="concat('place?id=', @ref)"/>
			<xsl:apply-templates/>
		</a>
	</xsl:template>
	
	<xsl:template match="TEI/text//title">
		<a class="semantic title" title="Werk der Musik">
			<xsl:attribute name="href" select="concat('title?id=', @ref)"/>
			<xsl:apply-templates/>
		</a>
	</xsl:template>
	
	<xsl:template match="TEI/text//orgName">
		<a class="semantic orgName" title="Ort">
			<xsl:attribute name="href" select="concat('org?id=', @ref)"/>
			<xsl:apply-templates/>
		</a>
	</xsl:template>
	
	<!-- bibliographic elements -->
	
	<xsl:template match="sourceDesc/bibl">
		<xsl:apply-templates/>
		<xsl:text>.</xsl:text>
	</xsl:template>
	
	<xsl:template match="sourceDesc//orgName[@role = 'publisher']">
		<xsl:value-of select="@ref"/>
	</xsl:template>
	
	<xsl:template match="sourceDesc//placeName">
		<xsl:text>(</xsl:text>
		<xsl:value-of select="@ref"/>
		<xsl:text>)</xsl:text>
	</xsl:template>
	
	<xsl:template match="sourceDesc//date[@when-iso]">
		<xsl:value-of select="@when-iso"/>
	</xsl:template>
	
	<xsl:template match="sourceDesc//series">
		<xsl:value-of select="."/>
	</xsl:template>

</xsl:stylesheet>