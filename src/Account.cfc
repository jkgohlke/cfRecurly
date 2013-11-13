<!---
   Copyright 2013 Jennifer Gohlke [jenny.gohlke@gmail.com]
   Copyright 2009 Bill Davidson, Brainbox.tv/tagtrigger.com [bill@brainbox.tv]

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

<cfcomponent displayname="cfRecurly.Account" hint="Represents an account in the recurly system" output="false">
    <cfset Variables.API = "">
    <cfset Variables.defaultFields = {
         id = ""
        ,username = ""
        ,email = ""
        ,first_name = ""
        ,last_name = ""
        ,company_name = ""
        ,address = {
             address1 = ""
            ,address2 = ""
            ,city = ""
            ,state_id = ""
            ,zip = ""
            ,country_id = ""
            ,phone = ""
        }
        <!--- Read-Only --->
        ,state = ""
        ,created_at = ""
    }>

    <cfset Variables.fields = duplicate( Variables.defaultFields )>

    <cfset Variables.objSubscription = createObject( "Subscription" )>

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
                returntype="Account">
        <cfargument name="fields" type="struct" required="true">

        <cfset Variables.fields = Variables.API.StructExtend( Variables.defaultFields, Arguments.fields )>
        <cfreturn this>
    </cffunction>

    <cffunction name="append"
                access="public"
                hint="Appends to the backing struct with the values of the passed struct."
                output="false"
                returntype="Account">
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

    <cffunction name="getBillingInfo"
                access="public"
                hint="Returns the billing information of this Account."
                output="false"
                returntype="BillingInfo">

        <cfreturn new BillingInfo( Variables.API, Variables.fields["id"] )>
    </cffunction>

    <cffunction name="reset"
                access="public"
                hint="Returns the backing struct to its default values."
                output="false"
                returntype="Account">

        <cfset Variables.fields = duplicate( Variables.defaultFields )>
        <cfreturn this>
    </cffunction>

    <cffunction name="areFieldsEmpty"
                access="private"
                output="false"
                returntype="boolean">
        <cfargument name="fields" type="struct" required="true">

        <cfset var isEmpty = true>

        <cfif not structIsEmpty( Arguments.fields )>
            <cfloop list="#structKeyList( Arguments.fields )#" index="fieldName">
                <cfif fieldName EQ "id">
                    <cfcontinue>
                </cfif>
                <cfset fieldValue = Arguments.fields[ fieldName ]>
                <cfif len( fieldValue )>
                    <cfset isEmpty = false>
                    <cfbreak>
                </cfif>
            </cfloop>
        </cfif>

        <cfreturn isEmpty>
    </cffunction>

    <cffunction name="isEmpty"
                access="public"
                output="false"
                returntype="boolean">

        <cfset var empty = true>

        <cfif isDefined("Variables.fields") AND not structIsEmpty( Variables.fields )>
            <cfset empty = areFieldsEmpty( Variables.fields )>
        </cfif>

        <cfreturn empty>
    </cffunction>

    <cffunction name="generateRawXML"
                access="package"
                output="true"
                returntype="string">
        <cfargument name="addId" type="boolean" required="true">

        <cfset Variables.fields = Variables.API.StructExtend( Variables.defaultFields, Variables.fields )>

        <cfset var strXML = "">
        <cfsavecontent variable="strXML">
        <cfoutput>
            <account>
                <cfif Arguments.addId>
                <account_code>#XmlFormat( Variables.fields["id"], true )#</account_code>
                </cfif>

                <cfif len( Variables.fields["username"] ) GT 0>
                <username>#XmlFormat( Variables.fields["username"], true )#</username>
                </cfif>

                <cfif len( Variables.fields["email"] ) GT 0>
                <email>#XmlFormat( Variables.fields["email"], true )#</email>
                </cfif>

                <cfif len( Variables.fields["first_name"] ) GT 0>
                <first_name>#XmlFormat( Variables.fields["first_name"], true )#</first_name>
                </cfif>

                <cfif len( Variables.fields["last_name"] ) GT 0>
                <last_name>#XmlFormat( Variables.fields["last_name"], true )#</last_name>
                </cfif>

                <cfif len( Variables.fields["company_name"] ) GT 0>
                <company_name>#XmlFormat( Variables.fields["company_name"], true )#</company_name>
                </cfif>

                <cfif NOT areFieldsEmpty( Variables.fields.address )>
                <address>
                    <cfif len( Variables.fields.address["address1"] ) GT 0>
                    <address1>#XmlFormat( Variables.fields.address["address1"], true )#</address1>
                    </cfif>
                    <cfif len( Variables.fields.address["address2"] ) GT 0>
                    <address2>#XmlFormat( Variables.fields.address["address2"], true )#</address2>
                    </cfif>
                    <cfif len( Variables.fields.address["city"] ) GT 0>
                    <city>#XmlFormat( Variables.fields.address["city"], true )#</city>
                    </cfif>
                    <cfif len( Variables.fields.address["state_id"] ) GT 0>
                    <state>#XmlFormat( Variables.fields.address["state_id"], true )#</state>
                    </cfif>
                    <cfif len( Variables.fields.address["zip"] ) GT 0>
                    <zip>#XmlFormat( Variables.fields.address["zip"], true )#</zip>
                    </cfif>
                    <cfif len( Variables.fields.address["country_id"] ) GT 0>
                    <country>#XmlFormat( Variables.fields.address["country_id"], true )#</country>
                    </cfif>
                    <cfif len( Variables.fields.address["phone"] ) GT 0>
                    <phone>#XmlFormat( Variables.fields.address["phone"], true )#</phone>
                    </cfif>
                </address>
                </cfif>
            </account>
        </cfoutput>
        </cfsavecontent>

        <cfreturn strXML>
    </cffunction>

    <cffunction name="generateXML"
                access="private"
                output="true"
                returntype="string">
        <cfargument name="addId" type="boolean" required="true">

        <cfset Variables.fields = Variables.API.StructExtend( Variables.defaultFields, Variables.fields )>
        
        <cfset var strXML = "">
        <cfsavecontent variable="strXML"><?xml version="1.0"?>
        <cfoutput>#generateRawXML( Arguments.addId )#</cfoutput>
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
        <cfif isDefined("xoResultNode.account")>
            <cfset var xoAccount = xoResultNode.account>
            <cfset newFields = {
                 id = isDefined("xoAccount.account_code.XmlText") ? xoAccount.account_code.XmlText : ""
                ,username = isDefined("xoAccount.username.XmlText") ? xoAccount.username.XmlText : ""
                ,email = isDefined("xoAccount.email.XmlText") ? xoAccount.email.XmlText : ""
                ,first_name = isDefined("xoAccount.first_name.XmlText") ? xoAccount.first_name.XmlText : ""
                ,last_name = isDefined("xoAccount.last_name.XmlText") ? xoAccount.last_name.XmlText : ""
                ,company_name = isDefined("xoAccount.company_name.XmlText") ? xoAccount.company_name.XmlText : ""
                ,address = {
                     address1 = isDefined("xoAccount.address.address1.XmlText") ? xoAccount.address.address1.XmlText : ""
                    ,address2 = isDefined("xoAccount.address.address2.XmlText") ? xoAccount.address.address2.XmlText : ""
                    ,city = isDefined("xoAccount.address.city.XmlText") ? xoAccount.address.city.XmlText : ""
                    ,state_id = isDefined("xoAccount.address.state.XmlText") ? xoAccount.address.state.XmlText : ""
                    ,zip = isDefined("xoAccount.address.zip.XmlText") ? xoAccount.address.zip.XmlText : ""
                    ,country_id = isDefined("xoAccount.address.country.XmlText") ? xoAccount.address.country.XmlText : ""
                    ,phone = isDefined("xoAccount.address.phone.XmlText") ? xoAccount.address.phone.XmlText : ""
                }

                <!--- Read-Only --->
                ,state = isDefined("xoAccount.state.XmlText") ? xoAccount.state.XmlText : ""
                ,created_at = isDefined("xoAccount.created_at.XmlText") ? xoAccount.created_at.XmlText : ""
            }>
        </cfif>
        <cfreturn newFields>
    </cffunction>

    <cffunction name="create"
                access="public"
                output="true"
                returntype="struct">

        <cfset var stAPICall = { data = "", headers = {}, status = ""} >
        <cfif len( Variables.fields["id"] ) GT 0>
            <cfset var strXML = generateXML( true )>
            <cfset stAPICall = Variables.API.post("accounts", strXML)>
            <!--- TODO: Handle errors --->
            <cfset refresh()>
        </cfif>
        <cfreturn stAPICall>
    </cffunction>

    <cffunction name="update"
                access="public"
                output="true"
                returntype="struct">

        <cfset var stAPICall = { data = "", headers = {}, status = ""} >
        <cfif len( Variables.fields["id"] ) GT 0>
            <cfset var strXML = generateXML( false )>
            <cfset stAPICall = Variables.API.put("accounts/#Variables.fields["id"]#", strXML)>
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
            <cfset stAPICall = Variables.API.get("accounts/#Arguments.AccountId#")>
            <!--- TODO: Handle errors --->
            <cfset Variables.fields = Variables.API.StructExtend( Variables.defaultFields, parseXML(stAPICall["data"]) )>
        </cfif>
        <cfreturn stAPICall>
    </cffunction>

    <cffunction name="close"
                access="public"
                output="true"
                returntype="struct">

        <cfset var stAPICall = { data = "", headers = {}, status = ""} >
        <cfif len( Variables.fields["id"] ) GT 0>
            <cfset stAPICall = Variables.API.delete("accounts/#Variables.fields["id"]#")>
            <!--- TODO: Handle errors --->
            <cfset refresh()>
        </cfif>
        <cfreturn stAPICall>
    </cffunction>

    <cffunction name="reopen"
                access="public"
                output="true"
                returntype="struct">

        <cfset var stAPICall = { data = "", headers = {}, status = ""} >
        <cfif len( Variables.fields["id"] ) GT 0>
            <cfset stAPICall = Variables.API.put("accounts/#Variables.fields["id"]#/reopen")>
            <!--- TODO: Handle errors --->
            <cfset refresh()>
        </cfif>
        <cfreturn stAPICall>
    </cffunction>

    <cffunction name="getSubscriptions"
                access="public"
                output="false"
                returntype="array">

        <cfif len( Variables.fields["id"] ) GT 0>
            <cfset var stAPICall = { data = "", headers = {}, status = ""} >
            <cfset stAPICall = Variables.API.get("accounts/#Variables.fields["id"]#/subscriptions")>
            <!--- TODO: Handle errors --->

            <cfset var arrRet = []>

            <cfif len( stAPICall["data"] )>
                <cfset var xoResultNode = xmlParse( stAPICall["data"] )>
                <cfif isDefined( "xoResultNode.subscriptions" )>
                    <cfset var xoSubscriptions = xoResultNode.subscriptions>
                    <cfloop index="idx" from="1" to="#ArrayLen(xoSubscriptions.XmlChildren)#">
                        <cfset var xoSubscription = xoSubscriptions.XmlChildren[ idx ]>
                        <cfset var stSubscription = Variables.objSubscription.parseXML( toString( xoSubscription ) )>
                        <cfset stSubscription["account_id"] = Variables.fields["id"]>
                        <cfset arrayAppend( arrRet, new Subscription( Variables.API, stSubscription ) )>
                    </cfloop>
                </cfif>
            </cfif>

            <cfreturn arrRet>
        </cfif>
        <cfreturn []>
    </cffunction>
</cfcomponent>