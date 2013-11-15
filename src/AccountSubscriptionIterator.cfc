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

<cfcomponent displayname="cfRecurly.AccountSubscriptionIterator" output="false">
    <cfset Variables.API = "">
    <cfset Variables.Util = createObject( "APIUtil" )>
    <cfset Variables.stLastReponse = { data = "", headers = {}, status = "" }>
    <cfset Variables.strStateFilter = "">
    <cfset Variables.iPerPage = "">

    <cfset Variables.cursorRegex = '[?|&]?cursor=([0-9\-]+).*>; rel="next"'>
    <cfset Variables.hasNextRegex = 'rel="next"'>

    <cfset Variables.objMyAccount = "">

    <cfset Variables.objSubscription = createObject( "Subscription" )>

    <cfset Variables.checkedForNext = false>
    <cfset Variables.hasNext = false>

    <cfset Variables.returnCachedOnNextCall = false>

    <cffunction name="init" access="public" output="true" hint="Constructor">
        <cfargument name="API" required="true">
        <cfargument name="Account" required="true" type="Account">
        <cfargument name="stateFilter" required="false" default="live" type="string" hint="active|canceled|expired|future|in_trial|live|past_due">
        <cfargument name="perPage" required="false" default="20" type="numeric">

        <cfset Variables.API = Arguments.API>
        <cfset Variables.objMyAccount = Arguments.Account>
        <cfset Variables.iPerPage = Arguments.perPage>
        <cfset Variables.strStateFilter = Arguments.stateFilter>

        <cfreturn this>
    </cffunction>

    <cffunction name="hasNext"
                access="public"
                output="true"
                returntype="boolean">
        <cfif Variables.checkedForNext EQ false>
            <cfset var arrRet = next()>
            <cfif Variables.checkedForNext>
                <cfset Variables.returnCachedOnNextCall = true>
                <cfif arraylen( arrRet ) GT 0>
                    <cfreturn true>
                </cfif>
            </cfif>
        </cfif>

        <cfreturn Variables.hasNext>
    </cffunction>

    <cffunction name="next"
                access="public"
                output="true"
                returntype="array">

        <cfset var stAPICall = { data = "", headers = {}, status = ""}>

        <cfset accountId = Variables.objMyAccount.get()["id"]>
        <cfif Variables.returnCachedOnNextCall>
            <cfset stAPICall = Variables.stLastReponse>
            <cfset Variables.returnCachedOnNextCall = false>
        <cfelse>
            <cfif Variables.Util.areFieldsEmpty( Variables.stLastReponse )>
                <cfset stAPICall = Variables.API.get("accounts/#accountId#/subscriptions", { "state" = Variables.strStateFilter, "per_page" = Variables.iPerPage })>
            <cfelse>
                <!--- NOTE: Obviously this is not RFC-5988 compliant... -J --->
                <cfset var strLink = isDefined("Variables.stLastReponse.headers.Link") ? Variables.stLastReponse.headers.Link : "">
                <cfset var cursor = "">
                <cfif len( strLink )>
                    <cfset arrFound = Variables.Util.FindWithRegex( Variables.cursorRegex, strLink )>
                    <cfif arraylen(arrFound) GT 1>
                        <cfset cursor = arrFound[2]>
                    </cfif>

                    <cfset stAPICall = Variables.API.get("accounts/#accountId#/subscriptions", { "state" = Variables.strStateFilter, "per_page" = Variables.iPerPage, "cursor" = cursor })>
                </cfif>
            </cfif>
        </cfif>

        <cfif len( stAPICall.data ) EQ 0>
            <cfset reset()>
            <cfreturn []>
        </cfif>

        <cfset Variables.stLastReponse = stAPICall>
        <cfset Variables.hasNext = reFind( Variables.hasNextRegex, isDefined("Variables.stLastReponse.headers.Link") ? Variables.stLastReponse.headers.Link : "" ) GT 0>
        <cfset Variables.checkedForNext = true>

        <cfset var arrRet = []>

        <cfif len( stAPICall["data"] )>
            <cfset var xoResultNode = xmlParse( stAPICall["data"] )>
            <cfif isDefined( "xoResultNode.subscriptions" )>
                <cfset var xoSubscriptions = xoResultNode.subscriptions>
                <cfloop index="idx" from="1" to="#ArrayLen(xoSubscriptions.XmlChildren)#">
                    <cfset var xoSubscription = xoSubscriptions.XmlChildren[ idx ]>
                    <cfset var stSubscription = Variables.objSubscription.parseXML( toString( xoSubscription ) )>
                    <cfset stSubscription["account_id"] = accountId>
                    <cfset arrayAppend( arrRet, new Subscription( Variables.API, stSubscription ) )>
                </cfloop>
            </cfif>
        </cfif>

        <cfreturn arrRet>
    </cffunction>

    <cffunction name="reset" access="public" output="false" returntype="AccountSubscriptionIterator">

        <cfset Variables.stLastReponse = {}>
        <cfset Variables.hasNext = false>
        <cfset Variables.checkedForNext = false>
        <cfset Variables.returnCachedOnNextCall = false>

        <cfreturn this>
    </cffunction>
</cfcomponent>