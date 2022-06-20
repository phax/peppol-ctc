<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
                xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"
                xmlns:ctc="urn:fdc:peppol.org:2020:ctc:schema:Report-1"
                xmlns="urn:oasis:names:specification:ubl:schema:xsd:ApplicationResponse-2"
                exclude-result-prefixes="ctc"
                version="2.0">

    <xsl:output method="xml" indent="yes"/>

    <xsl:param name="id" select="'000000000000'"/>

    <xsl:template match="ctc:Report">
        <ApplicationResponse>
            <cbc:CustomizationID>urn:fdc:peppol.org:2020:ctc:dt:billing:response:1.0</cbc:CustomizationID>
            <cbc:ProfileID>urn:fdc:peppol.org:2020:ctc:process:billing:clearing-report:1.0</cbc:ProfileID>

            <cbc:ID><xsl:value-of select="$id"/></cbc:ID>

            <cbc:IssueDate><xsl:value-of select="substring(string(current-date()), 1, 10)"/></cbc:IssueDate>
            <cbc:IssueTime><xsl:value-of select="substring(string(current-time()), 1, 8)"/></cbc:IssueTime>

            <cac:SenderParty>
                <xsl:apply-templates select="cac:ReceiverParty/cbc:EndpointID" mode="copy"/>
            </cac:SenderParty>
            <cac:ReceiverParty>
                <xsl:apply-templates select="cac:SenderParty/cbc:EndpointID" mode="copy"/>
            </cac:ReceiverParty>
            <cac:DocumentResponse>
                <cac:Response>
                    <cbc:ResponseCode>SUCCESS</cbc:ResponseCode>
                </cac:Response>
                <cac:DocumentReference>
                    <cbc:ID><xsl:value-of select="cbc:ID/normalize-space()"/></cbc:ID>
                    <cbc:IssueDate><xsl:value-of select="cbc:IssueDate/normalize-space()"/></cbc:IssueDate>
                    <cbc:IssueTime><xsl:value-of select="cbc:IssueTime/normalize-space()"/></cbc:IssueTime>
                </cac:DocumentReference>
            </cac:DocumentResponse>
        </ApplicationResponse>
    </xsl:template>

    <xsl:template match="cac:*" mode="copy">
        <xsl:element name="cac:{local-name()}">
            <xsl:apply-templates select="node() | @*" mode="copy"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="cbc:*" mode="copy">
        <xsl:element name="cbc:{local-name()}">
            <xsl:apply-templates select="node() | @*" mode="copy"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="node() | @*" mode="copy">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="copy"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>