<!---
   Copyright 2013 Jennifer Gohlke [jenny.gohlke@gmail.com]
   Copyright 2010 Bill Davidson, Brainbox.tv/tagtrigger.com [bill@brainbox.tv]

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
--->

<cfcomponent displayname="cfRecurly.BillingInfo" hint="Represents an accounts billing information in the recurly system" output="false">
    <cfset Variables.API = "">
    <cfset Variables.Util = createObject( "APIUtil" )>
    <cfset Variables.defaultFields = {
         id = ""
        ,first_name = ""
        ,last_name = ""
        ,address1 = ""
        ,address2 = ""
        ,city = ""
        ,state_id = ""
        ,zip = ""
        ,country_id = ""
        ,phone = ""
        ,vat_number = ""
        ,ip_address = ""

        <!--- Credit-card --->
        ,first_six = ""
        ,last_four = ""
        ,card_type = ""
        ,month = ""
        ,year = ""

        <!--- Write-Only --->
        ,number = ""
        ,verification_value = ""

        <!--- Read-Only --->
        ,ip_address_country = ""

        <!--- PayPal --->
        ,paypal_billing_agreement_id = ""
    }>

    <cfset Variables.fields = duplicate( Variables.defaultFields )>

    <cffunction name="init" access="public" output="true" hint="Constructor">
        <cfargument name="API" required="true">
        <cfargument name="AccountId" type="any" required="false" default="">

        <cfset Variables.API = Arguments.API>
        <cfif isStruct( Arguments.AccountId )>
            <cfset set( Arguments.AccountId )>
        <cfelseif isSimpleValue( Arguments.AccountId ) AND len( Arguments.AccountId ) GT 0>
            <cfset refresh( Arguments.AccountId )>
        </cfif>

        <cfreturn this>
    </cffunction>

    <cffunction name="set"
                access="public"
                hint="Sets the backing struct with the passed struct."
                output="false"
                returntype="BillingInfo">
        <cfargument name="fields" type="struct" required="true">

        <cfset Variables.fields = Variables.Util.StructExtend( Variables.defaultFields, Arguments.fields )>
        <cfreturn this>
    </cffunction>

    <cffunction name="append"
                access="public"
                hint="Appends to the backing struct with the values of the passed struct."
                output="false"
                returntype="BillingInfo">
        <cfargument name="fields" type="struct" required="true">

        <cfset Variables.fields = structAppend( Variables.fields, Arguments.fields )>
        <cfreturn this>
    </cffunction>

    <cffunction name="get"
                access="public"
                hint="Returns the backing struct that contains the fields of this object."
                output="false"
                returntype="struct">

        <cfreturn Variables.fields>
    </cffunction>

    <cffunction name="reset"
                access="public"
                hint="Returns the backing struct to its default values."
                output="false"
                returntype="BillingInfo">

        <cfset Variables.fields = duplicate( Variables.defaultFields )>
        <cfreturn this>
    </cffunction>

    <cffunction name="isEmpty"
                access="public"
                output="false"
                returntype="boolean">

        <cfset var empty = true>

        <cfif isDefined("Variables.fields") AND not structIsEmpty( Variables.fields )>
            <cfset empty = Variables.Util.areFieldsEmpty( Variables.fields )>
        </cfif>

        <cfreturn empty>
    </cffunction>

    <cffunction name="generateXML"
                access="private"
                output="true"
                returntype="string">

        <cfset Variables.fields = Variables.Util.StructExtend( Variables.defaultFields, Variables.fields )>

        <cfset var strXML = "">
        <cfsavecontent variable="strXML"><?xml version="1.0"?>
        <cfoutput>
            <billing_info>
                <cfif len( Variables.fields["first_name"] ) GT 0>
                <first_name>#XmlFormat( Variables.fields["first_name"], true )#</first_name>
                </cfif>

                <cfif len( Variables.fields["last_name"] ) GT 0>
                <last_name>#XmlFormat( Variables.fields["last_name"], true )#</last_name>
                </cfif>

                <cfif len( Variables.fields["address1"] ) GT 0>
                <address1>#XmlFormat( Variables.fields["address1"], true )#</address1>
                </cfif>

                <cfif len( Variables.fields["address2"] ) GT 0>
                <address2>#XmlFormat( Variables.fields["address2"], true )#</address2>
                </cfif>

                <cfif len( Variables.fields["city"] ) GT 0>
                <city>#XmlFormat( Variables.fields["city"], true )#</city>
                </cfif>

                <cfif len( Variables.fields["state_id"] ) GT 0>
                <state>#XmlFormat( Variables.fields["state_id"], true )#</state>
                </cfif>

                <cfif len( Variables.fields["country_id"] ) GT 0>
                <country>#XmlFormat( Variables.fields["country_id"], true )#</country>
                </cfif>

                <cfif len( Variables.fields["zip"] ) GT 0>
                <zip>#XmlFormat( Variables.fields["zip"], true )#</zip>
                </cfif>

                <cfif len( Variables.fields["phone"] ) GT 0>
                <phone>#XmlFormat( Variables.fields["phone"], true )#</phone>
                </cfif>

                <cfif len( Variables.fields["vat_number"] ) GT 0>
                <vat_number>#XmlFormat( Variables.fields["vat_number"], true )#</vat_number>
                </cfif>

                <cfif len( Variables.fields["ip_address"] ) GT 0>
                <ip_address>#XmlFormat( Variables.fields["ip_address"], true )#</ip_address>
                </cfif>

                <!--- Credit-card --->
                <cfif len( Variables.fields["number"] ) GT 0>
                <number>#XmlFormat( Variables.fields["number"], true )#</number>
                </cfif>

                <cfif len( Variables.fields["month"] ) GT 0>
                <month>#XmlFormat( Variables.fields["month"], true )#</month>
                </cfif>

                <cfif len( Variables.fields["year"] ) GT 0>
                <year>#XmlFormat( Variables.fields["year"], true )#</year>
                </cfif>

                <cfif len( Variables.fields["verification_value"] ) GT 0>
                <verification_value>#XmlFormat( Variables.fields["verification_value"], true )#</verification_value>
                </cfif>
            </billing_info>
        </cfoutput>
        </cfsavecontent>

        <cfreturn toString( xmlParse(strXML) )>
    </cffunction>

    <cffunction name="parseXML"
                access="package"
                output="false"
                returntype="struct">
        <cfargument name="xmlText" type="string" required="true">

        <cfset var newFields = {}>
        <cfif len( trim( Arguments.xmlText ) ) EQ 0>
            <cfreturn newFields>
        </cfif>

        <cfset var xoResultNode = xmlParse( Arguments.xmlText )>
        <cfif isDefined( "xoResultNode.billing_info" )>
            <cfset var xoBillingInfo = xoResultNode.billing_info>
            <cfset newFields = {
                 first_name = isDefined("xoBillingInfo.first_name.XmlText") ? xoBillingInfo.first_name.XmlText : ""
                ,last_name = isDefined("xoBillingInfo.last_name.XmlText") ? xoBillingInfo.last_name.XmlText : ""
                ,address1 = isDefined("xoBillingInfo.address1.XmlText") ? xoBillingInfo.address1.XmlText : ""
                ,address2 = isDefined("xoBillingInfo.address2.XmlText") ? xoBillingInfo.address2.XmlText : ""
                ,city = isDefined("xoBillingInfo.city.XmlText") ? xoBillingInfo.city.XmlText : ""
                ,state_id = isDefined("xoBillingInfo.state.XmlText") ? xoBillingInfo.state.XmlText : ""
                ,zip = isDefined("xoBillingInfo.zip.XmlText") ? xoBillingInfo.zip.XmlText : ""
                ,country_id = isDefined("xoBillingInfo.country.XmlText") ? xoBillingInfo.country.XmlText : ""
                ,phone = isDefined("xoBillingInfo.phone.XmlText") ? xoBillingInfo.phone.XmlText : ""
                ,vat_number = isDefined("xoBillingInfo.vat_number.XmlText") ? xoBillingInfo.vat_number.XmlText : ""
                ,ip_address = isDefined("xoBillingInfo.ip_address.XmlText") ? xoBillingInfo.ip_address.XmlText : ""

                <!--- Credit-card --->
                ,first_six = isDefined("xoBillingInfo.first_six.XmlText") ? xoBillingInfo.first_six.XmlText : ""
                ,last_four = isDefined("xoBillingInfo.last_four.XmlText") ? xoBillingInfo.last_four.XmlText : ""
                ,card_type = isDefined("xoBillingInfo.card_type.XmlText") ? xoBillingInfo.card_type.XmlText : ""
                ,month = isDefined("xoBillingInfo.month.XmlText") ? xoBillingInfo.month.XmlText : ""
                ,year = isDefined("xoBillingInfo.year.XmlText") ? xoBillingInfo.year.XmlText : ""

                <!--- Write-Only --->
                ,number = ""
                ,verification_value = ""

                <!--- PayPal --->
                ,paypal_billing_agreement_id = isDefined("xoBillingInfo.paypal_billing_agreement_id.XmlText") ? xoBillingInfo.paypal_billing_agreement_id.XmlText : ""

                <!--- Read-Only --->
                ,ip_address_country = isDefined("xoBillingInfo.ip_address_country.XmlText") ? xoBillingInfo.ip_address_country.XmlText : ""
            }>
        </cfif>
        <cfreturn newFields>
    </cffunction>

    <cffunction name="update"
                access="public"
                output="true"
                returntype="struct">

        <cfset var strXML = generateXML()>
        <cfif len( Variables.fields["id"] ) GT 0>
            <cfset var stAPICall = Variables.API.put("accounts/#Variables.fields["id"]#/billing_info", strXML)>
            <!--- TODO: Handle errors --->
            <cfset refresh()>
        </cfif>
        <cfreturn stAPICall>
    </cffunction>

    <cffunction name="refresh"
                access="public"
                output="true"
                returntype="struct">
        <cfargument name="AccountId" type="string" required="false" default="#Variables.fields["id"]#">

        <cfset var stAPICall = { data = "", headers = {}, status = ""} >
        <cfif len( Arguments.AccountId ) GT 0>
            <cfset stAPICall = Variables.API.get("accounts/#Arguments.AccountId#/billing_info")>
            <!--- TODO: Handle other errors --->
            <cfset Variables.fields = Variables.Util.StructExtend( Variables.defaultFields, parseXML(stAPICall["data"]) )>
            <cfset Variables.fields["id"] = Arguments.AccountId>
        </cfif>
        <cfreturn stAPICall>
    </cffunction>

    <cffunction name="delete"
                access="public"
                output="true"
                returntype="struct" >

        <cfset var stAPICall = { data = "", headers = {}, status = ""} >
        <cfif len( Variables.fields["id"] ) GT 0>
            <cfset stAPICall = Variables.API.delete("accounts/#Variables.fields["id"]#/billing_info")>
            <!--- TODO: Handle errors --->
            <cfset Variables.fields = duplicate( Variables.defaultFields )>
        </cfif>
        <cfreturn stAPICall>
    </cffunction>
</cfcomponent>