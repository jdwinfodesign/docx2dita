<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    version="3.0">
    
    <xsl:import href="../../dita-ot-3.6.1/plugins/org.dita4publishers.word2dita/xsl/docx2dita.xsl"/>
    
    <!-- sanity check that we are using the correct Word doc -->
    <xsl:template match="/" priority="20">
        <xsl:message>BASE URI: <xsl:value-of select="base-uri(.)"/></xsl:message>
        <xsl:next-match/>
    </xsl:template>
    
</xsl:stylesheet>