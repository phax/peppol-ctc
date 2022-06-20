<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
                xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"
                xmlns:ubl-creditnote="urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2"
                xmlns:ubl-invoice="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2"
                xmlns="urn:fdc:peppol.org:2020:ctc:schema:Report-1"
                exclude-result-prefixes="ubl-creditnote ubl-invoice"
                version="2.0">

    <xsl:output method="xml" indent="yes"/>

    <xsl:param name="sender" select="'9999:000000000'"/>
    <xsl:param name="receiver" select="'9999:000000000'"/>

    <xsl:template match="ubl-invoice:Invoice | ubl-creditnote:CreditNote">
        <Report>
            <cbc:CustomizationID>urn:fdc:peppol.org:2020:ctc:dt:billing:report:1.0</cbc:CustomizationID>
            <cbc:ProfileID>urn:fdc:peppol.org:2020:ctc:process:billing:clearing:1.0</cbc:ProfileID>

            <xsl:variable name="supplier">
                <xsl:choose>
                    <xsl:when test="cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID[@schemeID]">
                        <xsl:apply-templates select="cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID[@schemeID][1]" mode="id"/>
                    </xsl:when>
                    <xsl:when test="cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification/cbc:ID[@schemeID]">
                        <xsl:apply-templates select="cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification/cbc:ID[@schemeID][1]" mode="id"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="cac:AccountingSupplierParty/cac:Party/cbc:EndpointID" mode="id"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <xsl:variable name="customer">
                <xsl:choose>
                    <xsl:when test="cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID[@schemeID]">
                        <xsl:apply-templates select="cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID" mode="id"/>
                    </xsl:when>
                    <xsl:when test="cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID[@schemeID]">
                        <xsl:apply-templates select="cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID" mode="id"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="cac:AccountingCustomerParty/cac:Party/cbc:EndpointID" mode="id"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <xsl:variable name="fiscal-year">
                <xsl:value-of select="year-from-date(cbc:IssueDate)"/>
            </xsl:variable>

            <cbc:ID><xsl:value-of select="concat($supplier, '/', $customer, '/', cbc:ID/normalize-space(), '/', $fiscal-year)"/></cbc:ID>

            <cbc:IssueDate><xsl:value-of select="substring(string(current-date()), 1, 10)"/></cbc:IssueDate>
            <cbc:IssueTime><xsl:value-of select="substring(string(current-time()), 1, 8)"/></cbc:IssueTime>

            <xsl:apply-templates select="cbc:DocumentCurrencyCode" mode="copy"/>

            <cac:OriginalDocumentReference>
                <cbc:ID><xsl:value-of select="normalize-space(cbc:ID)"/></cbc:ID>
                <cbc:IssueDate><xsl:value-of select="normalize-space(cbc:IssueDate)"/></cbc:IssueDate>
                <xsl:if test="cbc:IssueTime">
                    <cbc:IssueTime><xsl:value-of select="substring(string(current-time()), 1, 8)"/></cbc:IssueTime>
                </xsl:if>
                <xsl:apply-templates select="cbc:InvoiceTypeCode | cbc:CreditNoteTypeCode"/>
            </cac:OriginalDocumentReference>

            <cac:SenderParty>
                <cbc:EndpointID schemeID="{substring($sender, 1, 4)}"><xsl:value-of select="substring($sender, 6)"/></cbc:EndpointID>
            </cac:SenderParty>

            <cac:ReceiverParty>
                <cbc:EndpointID schemeID="{substring($receiver, 1, 4)}"><xsl:value-of select="substring($receiver, 6)"/></cbc:EndpointID>
            </cac:ReceiverParty>

            <xsl:apply-templates select="cac:AccountingSupplierParty | cac:AccountingCustomerParty | cac:PayeeParty | cac:BuyerCustomerParty | cac:SellerSupplierParty | cac:TaxRepresentativeParty" mode="copy"/>

            <xsl:apply-templates select="cac:TaxTotal | cac:WithholdingTaxTotal | cac:LegalMonetaryTotal" mode="copy"/>
        </Report>
    </xsl:template>

    <xsl:template match="cbc:InvoiceTypeCode | cbc:CreditNoteTypeCode">
        <cbc:DocumentTypeCode><xsl:value-of select="normalize-space()"/></cbc:DocumentTypeCode>
    </xsl:template>

    <xsl:template match="cbc:CompanyID | cbc:EndpointID | cbc:ID" mode="id">
        <xsl:value-of select="concat((if (@schemeID) then concat(@schemeID, ':') else ''), normalize-space())"/>
    </xsl:template>

    <!-- Ignores -->
    <xsl:template match="cac:Contact | cac:PostalAddress" mode="copy"/>

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