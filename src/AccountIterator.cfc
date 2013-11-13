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

<cfcomponent displayname="cfRecurly.AccountIterator" output="false">
    <cfset Variables.API = "">
    <cfset Variables.stLastReponse = {}>
    <cfset Variables.strStateFilter = "">
    <cfset Variables.iPerPage = "">

    <cfset Variables.cursorRegex = "[?|&]?cursor=([0-9]+)">
    <cfset Variables.hasNextRegex = 'rel="next"'>

    <cfset Variables.objAccount = createObject( "Account" )>

    <cfset Variables.checkedForNext = false>
    <cfset Variables.hasNext = false>

    <cfset Variables.returnCachedOnNextCall = false>

    <cffunction name="init" access="public" output="true" hint="Constructor">
        <cfargument name="API" required="true">
        <cfargument name="stateFilter" required="false" default="active">
        <cfargument name="perPage" required="false" default="20">

        <cfset Variables.API = Arguments.API>
        <cfset Variables.strStateFilter = Arguments.stateFilter>
        <cfset Variables.iPerPage = Arguments.perPage>

        <cfreturn this>
    </cffunction>

    <cffunction name="hasNext"
                access="public"
                output="false"
                returntype="boolean">
        <cfif Variables.checkedForNext EQ false>
            <cfset next()>
            <cfset Variables.returnCachedOnNextCall = true>
        </cfif>

        <cfreturn Variables.hasNext>
    </cffunction>

    <cffunction name="next"
                access="public"
                output="false"
                returntype="array">

        <cfset var stAPICall = { data = "", headers = {}, status = ""} >

        <cfif Variables.returnCachedOnNextCall>
            <cfset stAPICall = Variables.stLastReponse>
            <cfset Variables.returnCachedOnNextCall = false>
        <cfelse>
            <cfif structIsEmpty( Variables.stLastReponse )>
                <cfset stAPICall = Variables.API.get("accounts", { "state" = Variables.strStateFilter, "per_page" = Variables.iPerPage })>
            <cfelse>
                <!--- NOTE: Obviously this is not RFC-5988 compliant... -J --->
                <cfset var strLink = isDefined("Variables.stLastReponse.headers.Link") ? Variables.stLastReponse.headers.Link : "">
                <cfset var cursor = "">
                <cfif len( strLink )>
                    <cfset arrFound = Variables.API.FindWithRegex( Variables.cursorRegex, strLink )>
                    <cfif arraylen(arrFound) GT 1>
                        <cfset cursor = arrFound[2]>
                    </cfif>

                    <cfset stAPICall = Variables.API.get("accounts", { "state" = Variables.strStateFilter, "per_page" = Variables.iPerPage, "cursor" = cursor })>
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
            <cfif isDefined( "xoResultNode.accounts" )>
                <cfset var xoAccounts = xoResultNode.accounts>
                <cfloop index="idx" from="1" to="#ArrayLen(xoAccounts.XmlChildren)#">
                    <cfset var xoAccount = xoAccounts.XmlChildren[ idx ]>
                    <cfset var stAccount = Variables.objAccount.parseXML( toString( xoAccount ) )>
                    <cfset arrayAppend( arrRet, new Account( Variables.API, stAccount ) )>
                </cfloop>
            </cfif>
        </cfif>

        <cfreturn arrRet>
    </cffunction>

    <cffunction name="reset" access="public" output="false" returntype="AccountIterator">

        <cfset Variables.stLastReponse = {}>
        <cfset Variables.hasNext = false>
        <cfset Variables.checkedForNext = false>
        <cfset Variables.returnCachedOnNextCall = false>

        <cfreturn this>
    </cffunction>
</cfcomponent>