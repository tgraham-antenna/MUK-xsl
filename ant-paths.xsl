<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0"
    xmlns:muk="http://markupuk.org/XSLT/Functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="muk xs">

<!-- Generate an Ant build file containing a <path> element for each
     XSLT file in $xsl.dir.  Each <path> contains a <pathelement> for
     each XSLT file on which the current XSLT file depends.

     Another build file will import the generated build file and use
     the paths to determine whether or not an XSLT file or any of its
     XSLT dependencies is newer than the target of the <xslt> task.
-->

<!-- ============================================================= -->
<!-- OUTPUT                                                        -->
<!-- ============================================================= -->

<xsl:output method="xml" indent="yes" />


<!-- ============================================================= -->
<!-- STYLESHEET PARAMETERS                                         -->
<!-- ============================================================= -->

<xsl:param
    name="project"
    select="'paths'"
    as="xs:string" />

<xsl:param
    name="single"
    select="()"
    as="xs:string?" />

<xsl:param
    name="xsl.dir"
    as="xs:string" />

<xsl:param
    name="timestamp"
    as="xs:string" />

<xsl:param
    name="verbose"
    as="xs:string?" />


<!-- ============================================================= -->
<!-- TEMPLATES                                                     -->
<!-- ============================================================= -->

<xsl:template name="muk:ant-paths">
  <xsl:if test="$verbose = ('true', 'yes')">
    <xsl:message>ant-paths.xsl <xsl:value-of select="$timestamp" /></xsl:message>
  </xsl:if>

  <xsl:comment> Autogenerated file.  DO NOT EDIT. </xsl:comment>
  <xsl:comment> Created: <xsl:value-of select="$timestamp" /> </xsl:comment>
  <project name="{$project}" basedir=".">
    <!--<xsl:message select="$xsl.dir" />-->
      <xsl:text>&#xA;</xsl:text>
    <xsl:comment> ============================================================= </xsl:comment>
      <xsl:text>&#xA;</xsl:text>
    <xsl:comment> Paths for dependencies of XSLT files. </xsl:comment>
    <xsl:for-each select="collection(concat('file:///', $xsl.dir, '?select=*.xsl'))">
      <xsl:sort />
      <xsl:variable name="base-uri" select="base-uri(.)" />
      <!--<xsl:message select="$base-uri" />-->
      <xsl:text>&#xA;</xsl:text>
      <xsl:comment> '<xsl:value-of select="$base-uri" />' and dependencies </xsl:comment>
      <xsl:text>&#xA;</xsl:text>
      <path id="{muk:basename($base-uri, '.xsl')}.path">
        <pathelement location="${{xsl.dir}}/{muk:basename($base-uri)}" /><xsl:sequence select="muk:dependencies(muk:basename($base-uri))" />
      </path>
    </xsl:for-each>
    <xsl:comment> <xsl:value-of select="$xsl.dir" /> </xsl:comment>
  </project>
</xsl:template>


<!-- ============================================================= -->
<!-- FUNCTIONS                                                     -->
<!-- ============================================================= -->

<xsl:function name="muk:dependencies">
  <xsl:param name="current" as="xs:string" />

  <xsl:sequence
      select="muk:dependencies($current,
                               $xsl.dir,
                               '${xsl.dir}')" />
</xsl:function>

<xsl:function name="muk:dependencies">
  <xsl:param name="current" as="xs:string" />
  <xsl:param name="dir" as="xs:string" />
  <xsl:param name="dir-name" as="xs:string" />

  <xsl:comment>
    <xsl:text> </xsl:text>
    <xsl:value-of select="$current" />
    <xsl:text> </xsl:text>
  </xsl:comment>
  <xsl:variable
      name="current-doc"
      select="if (doc-available(concat('file:///', $dir, '/', $current)))
                then document(concat('file:///', $dir, '/', $current))
	      else ()"
      as="document-node()?" />
<!--<xsl:comment select="if (exists($current-doc)) then concat('yes ', count($current-doc/*/xsl:import)) else 'no'" />-->
  <xsl:for-each select="$current-doc/*/xsl:import">
    <xsl:text>&#xA;    </xsl:text>
    <pathelement location="{$dir-name}/{@href}" />
    <xsl:sequence select="muk:dependencies(@href, $dir, $dir-name)" />
  </xsl:for-each>
</xsl:function>

<!-- Gets the last component of $uri. -->
<xsl:function name="muk:basename" as="xs:string">
  <xsl:param name="uri" as="xs:string" />

  <xsl:sequence select="tokenize($uri, '/|\\')[last()]" />
</xsl:function>

<!-- Gets the last component of $uri. -->
<xsl:function name="muk:basename" as="xs:string">
  <xsl:param name="uri" as="xs:string" />
  <xsl:param name="suffix" as="xs:string" />

  <xsl:variable name="suffix-regex"
		select="replace(concat(if (starts-with($suffix, '.')) then '' else '.', $suffix, '$'), '\.', '\\.')"
		as="xs:string" />

  <xsl:sequence select="replace(tokenize($uri, '/')[last()], $suffix-regex, '')" />
</xsl:function>

</xsl:stylesheet>
