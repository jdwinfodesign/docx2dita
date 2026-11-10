<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:local="urn:local-functions"
    xmlns:rsiwp="http://reallysi.com/namespaces/generic-wordprocessing-xml"
    xmlns:stylemap="urn:public:dita4publishers.org:namespaces:word2dita:style2tagmap"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    xmlns:relpath="http://dita2indesign/functions/relpath"
    
    exclude-result-prefixes="xs math"
    version="3.0">
    
    <xsl:import href="../../dita-ot-3.6.1/plugins/org.dita4publishers.word2dita/xsl/docx2dita.xsl"/>
    
    
    <xsl:template
        match="/"
        priority="10">
        <xsl:apply-templates select="." mode="report-parameters"/>
        <xsl:variable name="doDebug" as="xs:boolean" select="$debugBoolean"/>
        <!--    <xsl:variable name="stylesDoc" as="document-node()"
      select="document('styles.xml', .)"/>-->
        
        <xsl:variable name="stylesDoc" as="document-node()" select="document(concat(replace(base-uri(.), '[^/]+$', ''), 'styles.xml'))"/> 
        
        <xsl:message> + [INFO] ====================================</xsl:message>
        <xsl:message> + [INFO] Generating initial simple WP doc....</xsl:message>
        <xsl:message> + [INFO] ====================================</xsl:message>
        <xsl:variable
            name="simpleWpDocBase"
            as="element()">
            <xsl:call-template
                name="processDocumentXml">
                <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
                <xsl:with-param name="stylesDoc" as="document-node()" tunnel="yes"
                    select="$stylesDoc"/>
            </xsl:call-template>
        </xsl:variable>    
        <xsl:variable
            name="tempDoc"
            select="relpath:newFile($outputDir, 'simpleWpDoc.xml')"
            as="xs:string"/>
        <!-- NOTE: do not set this check to true(): it will fail when run within RSuite -->
        <xsl:if
            test="$doSaveIntermediateDocs">
            <xsl:result-document format="indented"
                href="{$tempDoc}">
                <xsl:message> + [DEBUG] Intermediate simple WP doc saved as <xsl:sequence
                        select="$tempDoc"/></xsl:message>
                <xsl:sequence
                    select="$simpleWpDocBase"/>
            </xsl:result-document>
        </xsl:if>
        
        <xsl:message> + [INFO] ====================================</xsl:message>
        <xsl:message> + [INFO] Doing level fixup....</xsl:message>
        <xsl:message> + [INFO] ====================================</xsl:message>
        <xsl:variable name="simpleWpDocLevelFixupResult" as="element()">
            <xsl:apply-templates select="$simpleWpDocBase" mode="simpleWpDoc-levelFixupRoot">
                <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
            </xsl:apply-templates>
            <!--      <xsl:sequence select="$simpleWpDocBase"/>-->
        </xsl:variable>
        
        <xsl:if
            test="$doSaveIntermediateDocs">
            <xsl:variable
                name="tempDocLevelFixup"
                select="relpath:newFile($outputDir, 'simpleWpDocLevelFixup.xml')"
                as="xs:string"/>
            <xsl:result-document format="indented"
                href="{$tempDocLevelFixup}">
                <xsl:message> + [DEBUG] Intermediate simple WP level fixup result doc saved as <xsl:sequence
                        select="$tempDocLevelFixup"/></xsl:message>
                <xsl:sequence
                    select="$simpleWpDocLevelFixupResult"/>
            </xsl:result-document>
        </xsl:if>
        
        <xsl:variable name="simpleWpDocMathTypeFixupResult"
            as="document-node()"
            >
            <xsl:choose>      
                <xsl:when test="$simpleWpDocLevelFixupResult//rsiwp:run[@style='MTConvertedEquation']">  
                    <xsl:message> + [INFO] ====================================</xsl:message>
                    <xsl:message> + [INFO] Doing MathType simpleWpDoc fixup....</xsl:message>
                    <xsl:message> + [INFO] ====================================</xsl:message>
                    <xsl:document>
                        <xsl:apply-templates select="$simpleWpDocLevelFixupResult" mode="simpleWpDoc-MathTypeFixup">
                            <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
                        </xsl:apply-templates>
                    </xsl:document>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:document>
                        <xsl:sequence select="$simpleWpDocLevelFixupResult"/>
                    </xsl:document>
                </xsl:otherwise>
            </xsl:choose>    
        </xsl:variable>
        
        <xsl:if
            test="$doSaveIntermediateDocs">
            <xsl:variable
                name="tempDocMathTypeFixup"
                select="relpath:newFile($outputDir, 'simpleWpDocMathTypeFixup.xml')"
                as="xs:string"/>
            <xsl:result-document format="indented"
                href="{$tempDocMathTypeFixup}">
                <xsl:message> + [DEBUG] Intermediate simple WP MathType fixup result doc saved as <xsl:sequence
                        select="$tempDocMathTypeFixup"/></xsl:message>
                <xsl:sequence
                    select="$simpleWpDocMathTypeFixupResult"/>
            </xsl:result-document>
        </xsl:if>
        
        <xsl:message> + [INFO] ====================================</xsl:message>
        <xsl:message> + [INFO] Doing general simpleWpDoc fixup....</xsl:message>
        <xsl:message> + [INFO] ====================================</xsl:message>
        
        <xsl:variable name="simpleWpDoc"
            as="document-node()"
            >
            <xsl:document>
                <xsl:apply-templates select="$simpleWpDocMathTypeFixupResult" mode="simpleWpDoc-fixup">
                    <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
                </xsl:apply-templates>
            </xsl:document>
        </xsl:variable>
        
        <xsl:if
            test="$doSaveIntermediateDocs">
            <xsl:variable
                name="tempDocFixup"
                select="relpath:newFile($outputDir, 'simpleWpDocFixup.xml')"
                as="xs:string"/>
            <xsl:result-document format="indented"
                href="{$tempDocFixup}">
                <xsl:message> + [DEBUG] Fixed-up simple WP doc saved as <xsl:sequence
                        select="$tempDocFixup"/></xsl:message>
                <xsl:sequence
                    select="$simpleWpDoc"/>
            </xsl:result-document>
        </xsl:if>
        
        <xsl:variable name="simpleWithLevels" as="document-node()">
            <xsl:document>
                <xsl:apply-templates select="$simpleWpDoc" mode="simpleWp-addLevels">
                    <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
                </xsl:apply-templates>
            </xsl:document>
        </xsl:variable>
        <xsl:if
            test="$doSaveIntermediateDocs">
            <xsl:variable
                name="tempDocFixup"
                select="relpath:newFile($outputDir, 'simpleWpWithLevels.xml')"
                as="xs:string"/>
            <xsl:result-document format="indented"
                href="{$tempDocFixup}">
                <xsl:message> + [DEBUG] Simple WP doc with levels added saved as <xsl:sequence
                        select="$tempDocFixup"/></xsl:message>
                <xsl:sequence
                    select="$simpleWithLevels"/>
            </xsl:result-document>
        </xsl:if>
        
        <xsl:message> + [INFO] ====================================</xsl:message>
        <xsl:message> + [INFO] Generating DITA result....</xsl:message>
        <xsl:message> + [INFO] ====================================</xsl:message>
        
        
        <xsl:apply-templates
            select="$simpleWithLevels/*"
            >
            <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
            <xsl:with-param 
                name="resultUrl" 
                select="relpath:newFile($outputDir, 'temp.output')" 
                tunnel="yes"        
            />
        </xsl:apply-templates>
        <xsl:message> + [INFO] ====================================</xsl:message>
        <xsl:message> + [INFO] Done.</xsl:message>
        <xsl:message> + [INFO] ====================================</xsl:message>
    </xsl:template>
    
    
    <!-- sanity check that we are using the correct Word doc -->
    <xsl:template match="/" priority="20">
        <xsl:message>BASE URI: <xsl:value-of select="base-uri(.)"/></xsl:message>
        <xsl:next-match/>
    </xsl:template>
    
    <!-- 11092026 The footnotesDoc variable does not find the file in the default XSL. -->
    <xsl:template match="w:footnoteReference">
        <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
        <xsl:if test="$doDebug">
            <xsl:message> + [DEBUG] Handling w:footnoteReference...</xsl:message>
        </xsl:if>
        
        <xsl:variable name="footnotesDoc" as="document-node()" 
            select="document(concat(replace(base-uri(.), '[^/]+$', ''), 'footnotes.xml'))"/> 
        
        <xsl:choose>
            <xsl:when test="not($footnotesDoc)">
                <xsl:message> + [WARN] Failed to find footnotes.xml file at </xsl:message>
                <fn>{Failed to find footnotes.xml file}</fn>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="targetId" as="xs:string"
                    select="@w:id"
                />
                <fn><xsl:apply-templates
                        select="$footnotesDoc/*/w:footnote[@w:id = $targetId]"
                        >
                        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
                </xsl:apply-templates></fn>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>