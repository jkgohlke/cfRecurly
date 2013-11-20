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

<cfcomponent displayname="cfRecurly.Subscription" hint="Represents a subscription in the recurly system" output="false">
    <cfset Variables.API = "">
    <cfset Variables.Util = createObject( "APIUtil" )>
    <cfset Variables.defaultFields = {
         id = ""
        ,account_id = ""
        ,plan_code = ""
        ,plan_name = ""
        ,state = ""
        ,unit_amount_in_cents = ""
        ,currency = ""
        ,quantity = ""
        ,activated_at = ""
        ,canceled_at = ""
        ,expires_at = ""
        ,current_period_started_at = ""
        ,current_period_ends_at = ""
        ,trial_started_at = ""
        ,trial_ends_at = ""
        <!---,subscription_add_ons = []--->
    }>

    <cfset Variables.accountIdRegex = "/accounts/([a-zA-Z0-9@\-_\.]+)">

    <cfset Variables.fields = duplicate( Variables.defaultFields )>

    <cffunction name="init" access="public" output="true" hint="Constructor">
        <cfargument name="API" required="true">
        <cfargument name="SubscriptionId" type="any" required="false" default="">

        <cfset Variables.API = Arguments.API>
        <cfif isStruct( Arguments.SubscriptionId )>
            <cfset set( Arguments.SubscriptionId )>
        <cfelseif isSimpleValue( Arguments.SubscriptionId ) AND len( Arguments.SubscriptionId ) GT 0>
            <cfset refresh( Arguments.SubscriptionId )>
        </cfif>

        <cfreturn this>
    </cffunction>

    <cffunction name="set"
                access="public"
                hint="Sets the backing struct with the passed struct."
                output="false"
                returntype="Subscription">
        <cfargument name="fields" type="struct" required="true">

        <cfset Variables.fields = Variables.Util.StructExtend( Variables.defaultFields, Arguments.fields )>
        <cfreturn this>
    </cffunction>

    <cffunction name="append"
                access="public"
                hint="Appends to the backing struct with the values of the passed struct."
                output="false"
                returntype="Subscription">
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
                returntype="Subscription">

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
            <subscription>
                <cfif len( Variables.fields["plan_code"] ) GT 0>
                <plan_code>#XmlFormat( Variables.fields["plan_code"], true )#</plan_code>
                </cfif>

                #objAccount.generateRawXML( true )#

                <!--- TODO: subscription_add_ons --->

                <cfif len( Variables.fields["coupon_code"] ) GT 0>
                <coupon_code>#XmlFormat( Variables.fields["coupon_code"], true )#</coupon_code>
                </cfif>

                <cfif len( Variables.fields["unit_amount_in_cents"] ) GT 0>
                <unit_amount_in_cents>#XmlFormat( ToString( int( Variables.fields["unit_amount_in_cents"] ) ), true )#</unit_amount_in_cents>
                </cfif>

                <cfif len( Variables.fields["currency"] ) GT 0>
                <currency>#XmlFormat( Variables.fields["currency"], true )#</currency>
                </cfif>

                <cfif len( Variables.fields["quantity"] ) GT 0>
                <quantity>#XmlFormat( ToString( int( Variables.fields["quantity"] ) ), true )#</quantity>
                </cfif>

                <cfif isDate( Variables.fields["trial_ends_at"] )>
                <trial_ends_at>#XmlFormat( Variables.API.GetIsoTimeString( Variables.fields["trial_ends_at"], true ), true )#</trial_ends_at>
                </cfif>

                <cfif isDate( Variables.fields["starts_at"] )>
                <starts_at>#XmlFormat( Variables.API.GetIsoTimeString( Variables.fields["starts_at"], true ), true )#</starts_at>
                </cfif>

                <cfif len( Variables.fields["total_billing_cycles"] ) GT 0>
                <total_billing_cycles>#XmlFormat( ToString( int( Variables.fields["total_billing_cycles"] ) ), true )#</total_billing_cycles>
                </cfif>

                <cfif isDate( Variables.fields["first_renewal_date"] )>
                <first_renewal_date>#XmlFormat( Variables.API.GetIsoTimeString( Variables.fields["first_renewal_date"], true ), true )#</first_renewal_date>
                </cfif>

            </subscription>
        </cfoutput>
        </cfsavecontent>

        <cfreturn toString( xmlParse(strXML) )>
    </cffunction>

    <cffunction name="generateUpdateXML"
                access="private"
                output="true"
                returntype="string">
        <cfargument name="timeframe" type="string" required="true" hint="now|renewal">

        <cfif NOT listContainsNoCase( "now,renewal", Arguments.timeframe )>
            <cfthrow type="cfRecurly" message="Invalid value '#Arguments.timeframe#' for parameter 'timeframe' for function 'generateUpdateXML'."/>
        </cfif>

        <cfset Variables.fields = Variables.Util.StructExtend( Variables.defaultFields, Variables.fields )>

        <cfset var strXML = "">
        <cfsavecontent variable="strXML"><?xml version="1.0"?>
        <cfoutput>
            <subscription>
                <timeframe>#XmlFormat( Arguments.timeframe, true )#</timeframe>

                <cfif len( Variables.fields["plan_code"] ) GT 0>
                <plan_code>#XmlFormat( Variables.fields["plan_code"], true )#</plan_code>
                </cfif>

                <cfif len( Variables.fields["quantity"] ) GT 0>
                <quantity>#XmlFormat( ToString( int( Variables.fields["quantity"] ) ), true )#</quantity>
                </cfif>

                <cfif len( Variables.fields["unit_amount_in_cents"] ) GT 0>
                <unit_amount_in_cents>#XmlFormat( ToString( int( Variables.fields["unit_amount_in_cents"] ) ), true )#</unit_amount_in_cents>
                </cfif>

                <!--- TODO: subscription_add_ons:

                  <subscription_add_ons>
                    <subscription_add_on>
                      <add_on_code>ipaddresses</add_on_code>
                      <quantity>10</quantity>
                      <unit_amount_in_cents>150</unit_amount_in_cents>
                    </subscription_add_on>
                  </subscription_add_ons>

                 --->

            </subscription>
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
        <cfif isDefined( "xoResultNode.subscription" )>
            <cfset var xoSubscription = xoResultNode.subscription>
            <cfset var accountIdUrl = isDefined("xoTransaction.account.XmlAttributes.href") ? xoTransaction.account.XmlAttributes.href : "">
            <cfset var accountId = "">
            <cfif len( accountIdUrl )>
                <cfset arrFound = Variables.Util.FindWithRegex( Variables.accountIdRegex, accountIdUrl )>
                <cfif arraylen(arrFound) GT 1>
                    <cfset accountId = arrFound[2]>
                </cfif>
            </cfif>
            <cfset newFields = {
                 id = isDefined("xoSubscription.uuid.XmlText") ? xoSubscription.uuid.XmlText : ""
                ,account_id = accountId
                ,plan_code = isDefined("xoSubscription.plan.plan_code.XmlText") ? xoSubscription.plan.plan_code.XmlText : ""
                ,plan_name = isDefined("xoSubscription.plan.name.XmlText") ? xoSubscription.plan.name.XmlText : ""
                ,state = isDefined("xoSubscription.state.XmlText") ? xoSubscription.state.XmlText : ""
                ,unit_amount_in_cents = isDefined("xoSubscription.unit_amount_in_cents.XmlText") ? xoSubscription.unit_amount_in_cents.XmlText : ""
                ,currency = isDefined("xoSubscription.currency.XmlText") ? xoSubscription.currency.XmlText : ""
                ,quantity = isDefined("xoSubscription.quantity.XmlText") ? xoSubscription.quantity.XmlText : ""
                ,activated_at = isDefined("xoSubscription.activated_at.XmlText") ? xoSubscription.activated_at.XmlText : ""
                ,canceled_at = isDefined("xoSubscription.canceled_at.XmlText") ? xoSubscription.canceled_at.XmlText : ""
                ,expires_at = isDefined("xoSubscription.expires_at.XmlText") ? xoSubscription.expires_at.XmlText : ""
                ,current_period_started_at = isDefined("xoSubscription.current_period_started_at.XmlText") ? xoSubscription.current_period_started_at.XmlText : ""
                ,current_period_ends_at = isDefined("xoSubscription.current_period_ends_at.XmlText") ? xoSubscription.current_period_ends_at.XmlText : ""
                ,trial_started_at = isDefined("xoSubscription.trial_started_at.XmlText") ? xoSubscription.trial_started_at.XmlText : ""
                ,trial_ends_at = isDefined("xoSubscription.trial_ends_at.XmlText") ? xoSubscription.trial_ends_at.XmlText : ""

                <!--- TODO: subscription_add_ons --->
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
            <cfset stAPICall = Variables.API.post("subscriptions", strXML)>
            <cfset Variables.fields = Variables.Util.StructExtend( Variables.defaultFields, parseXML(stAPICall["data"]) )>
            <!--- TODO: Handle errors --->
            <cfset refresh()>
        </cfif>
        <cfreturn stAPICall>
    </cffunction>

    <cffunction name="update"
                access="public"
                output="true"
                returntype="struct">
        <cfargument name="timeframe" type="string" required="true" hint="now|renewal">

        <cfset var stAPICall = { data = "", headers = {}, status = ""} >
        <cfif len( Variables.fields["id"] ) GT 0>
            <cfset var strXML = generateUpdateXML( Arguments.timeframe )>
            <cfset var stAPICall = Variables.API.put("subscriptions/#Variables.fields["id"]#", strXML)>
            <!--- TODO: Handle errors --->
            <cfset refresh()>
        </cfif>
        <cfreturn stAPICall>
    </cffunction>

    <cffunction name="refresh"
                access="public"
                output="true"
                returntype="struct">
        <cfargument name="SubscriptionId" type="string" required="false" default="#Variables.fields["id"]#">

        <cfset var stAPICall = { data = "", headers = {}, status = ""} >
        <cfif len( Arguments.SubscriptionId ) GT 0>
            <cfset stAPICall = Variables.API.get("subscriptions/#Arguments.SubscriptionId#")>
            <!--- TODO: Handle other errors --->
            <cfset Variables.fields = Variables.Util.StructExtend( Variables.defaultFields, parseXML(stAPICall["data"]) )>
            <cfset Variables.fields["id"] = Arguments.SubscriptionId>
        </cfif>
        <cfreturn stAPICall>
    </cffunction>

    <cffunction name="cancel"
                access="public"
                output="true"
                returntype="struct" >

        <cfset var stAPICall = { data = "", headers = {}, status = ""} >
        <cfif len( Variables.fields["id"] ) GT 0>
            <cfset stAPICall = Variables.API.put("subscriptions/#Variables.fields["id"]#/cancel")>
            <!--- TODO: Handle errors --->
            <cfset Variables.fields = duplicate( Variables.defaultFields )>
        </cfif>
        <cfreturn stAPICall>
    </cffunction>

    <cffunction name="reactivate"
                access="public"
                output="true"
                returntype="struct" >

        <cfset var stAPICall = { data = "", headers = {}, status = ""} >
        <cfif len( Variables.fields["id"] ) GT 0>
            <cfset stAPICall = Variables.API.put("subscriptions/#Variables.fields["id"]#/reactivate")>
            <!--- TODO: Handle errors --->
            <cfset Variables.fields = duplicate( Variables.defaultFields )>
        </cfif>
        <cfreturn stAPICall>
    </cffunction>

    <cffunction name="terminate"
                access="public"
                output="true"
                returntype="struct" >
        <cfargument name="strRefundType" type="string" required="true" hint="partial|full|none">

        <cfset var stAPICall = { data = "", headers = {}, status = ""} >
        <cfif len( Variables.fields["id"] ) GT 0>
            <cfset stAPICall = Variables.API.put( "subscriptions/#Variables.fields["id"]#/terminate", { refund = Arguments.strRefundType } )>
            <!--- TODO: Handle errors --->
            <cfset Variables.fields = duplicate( Variables.defaultFields )>
        </cfif>
        <cfreturn stAPICall>
    </cffunction>

    <cffunction name="postpone"
                access="public"
                output="true"
                returntype="struct" >
        <cfargument name="dtNextRenewal" type="date" required="true">

        <cfset Arguments.dtNextRenewal = Variables.API.GetIsoTimeString( Arguments.dtNextRenewal )>

        <cfset var stAPICall = { data = "", headers = {}, status = ""} >
        <cfif len( Variables.fields["id"] ) GT 0>
            <cfset stAPICall = Variables.API.put("subscriptions/#Variables.fields["id"]#/postpone", { next_renewal_date = Arguments.dtNextRenewal })>
            <!--- TODO: Handle errors --->
            <cfset Variables.fields = duplicate( Variables.defaultFields )>
        </cfif>
        <cfreturn stAPICall>
    </cffunction>
</cfcomponent>