<!---
   Copyright 2013 Jennifer Gohlke [jenny.gohlke@gmail.com]

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

<cfcomponent displayname="cfRecurly.Transaction" hint="Represents a transaction in the recurly system" output="false">
    <cfset Variables.API = "">
    <cfset Variables.Util = createObject( "APIUtil" )>
    <cfset Variables.defaultFields = {
         id = ""
        ,account_id = ""
        ,type = ""
        ,action = ""
        ,amount_in_cents = ""
        ,tax_in_cents = ""
        ,currency = ""
        ,status = ""
        ,payment_method = ""
        ,reference = ""
        ,source = ""
        ,recurring = ""
        ,test = ""
        ,voidable = ""
        ,refundable = ""
        ,cvv_result = ""
        ,avs_result = ""
        ,avs_result_street = ""
        ,avs_result_postal = ""
        ,created_at = ""
        ,cached_account_details = {}
        ,cached_billing_details = {}
    }>

    <cfset Variables.accountIdRegex = "/accounts/([a-zA-Z0-9@\-_\.]+)">

    <cfset Variables.fields = duplicate( Variables.defaultFields )>

    <cfset Variables.objAccount = createObject( "Account" )>
    <cfset Variables.objBillingInfo = createObject( "BillingInfo" )>

    <cffunction name="init" access="public" output="true" hint="Constructor">
        <cfargument name="API" required="true">
        <cfargument name="TransactionId" type="any" required="false" default="">

        <cfset Variables.API = Arguments.API>
        <cfif isStruct( Arguments.TransactionId )>
            <cfset set( Arguments.TransactionId )>
        <cfelseif isSimpleValue( Arguments.TransactionId ) AND len( Arguments.TransactionId ) GT 0>
            <cfset refresh( Arguments.TransactionId )>
        </cfif>

        <cfreturn this>
    </cffunction>

    <cffunction name="set"
                access="public"
                hint="Sets the backing struct with the passed struct."
                output="false"
                returntype="Transaction">
        <cfargument name="fields" type="struct" required="true">

        <cfset Variables.fields = Variables.Util.StructExtend( Variables.defaultFields, Arguments.fields )>
        <cfreturn this>
    </cffunction>

    <cffunction name="append"
                access="public"
                hint="Appends to the backing struct with the values of the passed struct."
                output="false"
                returntype="Transaction">
        <cfargument name="fields" type="struct" required="true">

        <cfset Variables.fields = Variables.Util.StructExtend( Variables.fields, Arguments.fields )>
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
                returntype="Transaction">

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

    <cffunction name="generateCreateXML"
                access="private"
                output="true"
                returntype="string">
        <cfargument name="objAccount" type="Account" required="true">

        <cfset Variables.fields = Variables.Util.StructExtend( Variables.defaultFields, Variables.fields )>

        <cfset var strXML = "">
        <cfsavecontent variable="strXML"><?xml version="1.0"?>
        <cfoutput>
            <transaction>
                <cfif len( Variables.fields["account_id"] ) GT 0>
                <account>
                    <account_code>#XmlFormat( Variables.fields["account_id"], true )#</account_code>
                </account>
                </cfif>

                <cfif len( Variables.fields["amount_in_cents"] ) GT 0>
                <amount_in_cents>#XmlFormat( Variables.fields["amount_in_cents"], true )#</amount_in_cents>
                </cfif>

                <cfif len( Variables.fields["currency"] ) GT 0>
                <currency>#XmlFormat( Variables.fields["currency"], true )#</currency>
                </cfif>

                <cfif len( Variables.fields["description"] ) GT 0>
                <description>#XmlFormat( Variables.fields["description"], true )#</description>
                </cfif>
            </transaction>
        </cfoutput>
        </cfsavecontent>

        <cfreturn toString( xmlParse(strXML) )>
    </cffunction>

    <cffunction name="parseXML"
                access="package"
                output="true"
                returntype="struct">
        <cfargument name="xmlText" type="string" required="true">

        <cfset var newFields = {}>
        <cfif len( trim( Arguments.xmlText ) ) EQ 0>
            <cfreturn newFields>
        </cfif>

        <cfset var xoResultNode = xmlParse( Arguments.xmlText )>
        <cfif isDefined( "xoResultNode.transaction" )>
            <cfset var xoTransaction = xoResultNode.transaction>
            <cfset var accountIdUrl = isDefined("xoTransaction.account.XmlAttributes.href") ? xoTransaction.account.XmlAttributes.href : "">
            <cfset var accountId = "">
            <cfif len( accountIdUrl )>
                <cfset arrFound = Variables.Util.FindWithRegex( Variables.accountIdRegex, accountIdUrl )>
                <cfif arraylen(arrFound) GT 1>
                    <cfset accountId = arrFound[2]>
                </cfif>
            </cfif>
            <cfset newFields = {
                 id = isDefined("xoTransaction.uuid.XmlText") ? xoTransaction.uuid.XmlText : ""
                ,account_id = accountId
                ,type = isDefined("xoTransaction.XmlAttributes.type") ? xoTransaction.XmlAttributes.type : ""
                ,action = isDefined("xoTransaction.action.XmlText") ? xoTransaction.action.XmlText : ""
                ,amount_in_cents = isDefined("xoTransaction.amount_in_cents.XmlText") ? xoTransaction.amount_in_cents.XmlText : ""
                ,tax_in_cents = isDefined("xoTransaction.tax_in_cents.XmlText") ? xoTransaction.tax_in_cents.XmlText : ""
                ,currency = isDefined("xoTransaction.currency.XmlText") ? xoTransaction.currency.XmlText : ""
                ,status = isDefined("xoTransaction.status.XmlText") ? xoTransaction.status.XmlText : ""
                ,payment_method = isDefined("xoTransaction.payment_method.XmlText") ? xoTransaction.payment_method.XmlText : ""
                ,reference = isDefined("xoTransaction.reference.XmlText") ? xoTransaction.reference.XmlText : ""
                ,source = isDefined("xoTransaction.source.XmlText") ? xoTransaction.source.XmlText : ""
                ,recurring = isDefined("xoTransaction.recurring.XmlText") ? xoTransaction.recurring.XmlText : ""
                ,test = isDefined("xoTransaction.test.XmlText") ? xoTransaction.test.XmlText : ""
                ,voidable = isDefined("xoTransaction.voidable.XmlText") ? xoTransaction.voidable.XmlText : ""
                ,refundable = isDefined("xoTransaction.refundable.XmlText") ? xoTransaction.refundable.XmlText : ""
                ,cvv_result = isDefined("xoTransaction.cvv_result.XmlText") ? xoTransaction.cvv_result.XmlText : ""
                ,avs_result = isDefined("xoTransaction.avs_result.XmlText") ? xoTransaction.avs_result.XmlText : ""
                ,avs_result_street = isDefined("xoTransaction.avs_result_street.XmlText") ? xoTransaction.avs_result_street.XmlText : ""
                ,avs_result_postal = isDefined("xoTransaction.avs_result_postal.XmlText") ? xoTransaction.avs_result_postal.XmlText : ""
                ,created_at = isDefined("xoTransaction.created_at.XmlText") ? xoTransaction.created_at.XmlText : ""
                ,cached_account_details = isDefined("xoTransaction.details.account") ? Variables.objAccount.parseXML( ToString( xoTransaction.details.account ) ) : {}
                ,cached_billing_details = isDefined("xoTransaction.details.account.billing_info") ? Variables.objBillingInfo.parseXML( ToString( xoTransaction.details.account.billing_info ) ) : {}
            }>
        </cfif>
        <cfreturn newFields>
    </cffunction>

    <cffunction name="create"
                access="public"
                output="true"
                returntype="struct">
        <cfargument name="objAccount" type="Account" required="true">

        <cfset var stAPICall = { data = "", headers = {}, status = ""} >
        <cfif len( Variables.fields["id"] ) GT 0>
            <cfset var strXML = generateCreateXML( Arguments.objAccount )>
            <cfset stAPICall = Variables.API.post("transactions", strXML)>
            <!--- TODO: Handle errors --->
            <cfset refresh()>
        </cfif>
        <cfreturn stAPICall>
    </cffunction>

    <cffunction name="refresh"
                access="public"
                output="true"
                returntype="struct">
        <cfargument name="TransactionId" type="string" required="false" default="#Variables.fields["id"]#">

        <cfset var stAPICall = { data = "", headers = {}, status = ""} >
        <cfif len( Arguments.TransactionId ) GT 0>
            <cfset stAPICall = Variables.API.get("transactions/#Arguments.TransactionId#")>
            <!--- TODO: Handle other errors --->
            <cfset Variables.fields = Variables.Util.StructExtend( Variables.defaultFields, parseXML(stAPICall["data"]) )>
            <cfset Variables.fields["id"] = Arguments.TransactionId>
        </cfif>
        <cfreturn stAPICall>
    </cffunction>

    <cffunction name="refund"
                access="public"
                output="true"
                returntype="struct" >
        <cfargument name="iRefundAmountInCents" type="int" required="false" default="0">

        <cfset var stAPICall = { data = "", headers = {}, status = ""} >
        <cfif len( Variables.fields["id"] ) GT 0>
            <cfif iRefundAmountInCents EQ 0>
                <cfset stAPICall = Variables.API.delete("transactions/#Variables.fields["id"]#")>
            <cfelse>
                <cfset stAPICall = Variables.API.delete("transactions/#Variables.fields["id"]#", { amount_in_cents = Arguments.iRefundAmountInCents })>
            </cfif>
            <!--- TODO: Handle errors --->
            <cfset Variables.fields = duplicate( Variables.defaultFields )>
        </cfif>
        <cfreturn stAPICall>
    </cffunction>
</cfcomponent>