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

<cfcomponent displayname="cfRecurly.API" hint="Wraps the base Recurly RESTful API interactions" output="false">
    <cfset Variables.apiBaseURL = "">
    <cfset Variables.apiKey = "">

    <cfset Variables.Util = createObject( "APIUtil" )>

    <cffunction name="init" access="public" output="false" hint="Constructor">
        <cfargument name="apiSubdomain">
        <cfargument name="apiKey">

        <cfset Variables.apiBaseURL = "https://#Arguments.apiSubdomain#.recurly.com/v2">
        <cfset Variables.apiKey = Arguments.apiKey>

        <cfreturn this>
    </cffunction>

    <cffunction name="get" access="public" returntype="struct" output="false">
        <cfargument name="uriArguments" type="string" required="true">
        <cfargument name="queryParameters" type="struct" required="false" default="#{}#">

        <cfset var stRet = {
             data = ""
            ,headers = {}
            ,status = "000 Unknown"
            ,endpoint = ""
            ,error = false
            ,error_message = ""
        }>
        <cfset var httpResponse = {}>
        <cftry>
            <cfset Arguments.uriArguments = reReplace( Arguments.uriArguments, "^[/]+", "", "ALL" )>
            <cfset var strUrl = "#Variables.APIbaseURL#/#Arguments.uriArguments#">
            <cfif NOT structIsEmpty( Arguments.queryParameters )>
                <cfset var strUrl = Variables.Util.AppendURLTokens( strUrl, queryParameters )>
            </cfif>
            <cfset stRet["endpoint"] = strUrl>

            <cfset var httpResponse = {}>
            <cfhttp url="#strUrl#"
                    username="#Variables.apiKey#"
                    password=""
                    method="GET"
                    timeout="60"
                    throwonerror="false"
                    result="httpResponse">
                <cfhttpparam type="header"
                             encoded="false"
                             name="Accept"
                             value="application/xml">
            </cfhttp>

            <cfset stRet["data"] = (isDefined("httpResponse.fileContent") ? toString( httpResponse.fileContent ) : stRet.data)>
            <cfset stRet["headers"] = (isDefined("httpResponse.responseHeader") ? httpResponse.responseHeader : stRet.headers)>
            <cfset stRet["status"] = (isDefined("httpResponse.statusCode") ? toString( httpResponse.statusCode ) : stRet.status)>

            <cfcatch type="any">
                <!---<cfthrow type="cfRecurly" message="An API error occurred." detail="#cfcatch.message#">--->
                <cfset stRet["error"] = true>
                <cfset stRet["error_message"] = cfcatch.message>
            </cfcatch>
        </cftry>

        <cfreturn stRet>
    </cffunction>

    <cffunction name="post" access="public" returntype="struct" output="false">
        <cfargument name="uriArguments" type="string" required="true">
        <cfargument name="xmlContent" type="any" required="false" default="">
        <cfargument name="queryParameters" type="struct" required="false" default="#{}#">

        <cfif isStruct( Arguments.xmlContent )>
            <cfset Arguments.queryParameters = Arguments.xmlContent>
            <cfset Arguments.xmlContent = "">
        </cfif>

        <cfset var stRet = {
             data = ""
            ,headers = {}
            ,status = "000 Unknown"
            ,endpoint = ""
            ,error = false
            ,error_message = ""
        }>
        <cfset var httpResponse = {}>
        <cftry>
            <cfset Arguments.uriArguments = reReplace( Arguments.uriArguments, "^[/]+", "", "ALL" )>
            <cfset var strUrl = "#Variables.APIbaseURL#/#Arguments.uriArguments#">
            <cfif NOT structIsEmpty( Arguments.queryParameters )>
                <cfset var strUrl = Variables.Util.AppendURLTokens( strUrl, queryParameters )>
            </cfif>
            <cfset stRet["endpoint"] = strUrl>

            <cfset var httpResponse = {}>
            <cfhttp url="#strUrl#"
                    username="#Variables.apiKey#"
                    password=""
                    method="POST"
                    timeout="60"
                    throwonerror="false"
                    result="httpResponse">
                <cfhttpparam type="header"
                             encoded="false"
                             name="Accept"
                             value="application/xml">
                <cfif isDefined("Arguments.xmlContent") AND len( trim( toString( Arguments.xmlContent ) ) ) GT 0>
                    <cfhttpparam type="xml"
                                 value="#trim( toString( Arguments.xmlContent ) )#">
                </cfif>
            </cfhttp>

            <cfset stRet["data"] = (isDefined("httpResponse.fileContent") ? toString( httpResponse.fileContent ) : stRet.data)>
            <cfset stRet["headers"] = (isDefined("httpResponse.responseHeader") ? httpResponse.responseHeader : stRet.headers)>
            <cfset stRet["status"] = (isDefined("httpResponse.statusCode") ? toString( httpResponse.statusCode ) : stRet.status)>

            <cfcatch type="any">
                <!---<cfthrow type="cfRecurly" message="An API error occurred." detail="#cfcatch.message#">--->
                <cfset stRet["error"] = true>
                <cfset stRet["error_message"] = cfcatch.message>
            </cfcatch>
        </cftry>

        <cfreturn stRet>
    </cffunction>

    <cffunction name="put" access="public" returntype="struct" output="false">
        <cfargument name="uriArguments" type="string" required="true">
        <cfargument name="xmlContent" type="any" required="false" default="">
        <cfargument name="queryParameters" type="struct" required="false" default="#{}#">

        <cfif isStruct( Arguments.xmlContent )>
            <cfset Arguments.queryParameters = Arguments.xmlContent>
            <cfset Arguments.xmlContent = "">
        </cfif>

        <cfset var stRet = {
             data = ""
            ,headers = {}
            ,status = "000 Unknown"
            ,endpoint = ""
            ,error = false
            ,error_message = ""
        }>
        <cfset var httpResponse = {}>
        <cftry>
            <cfset Arguments.uriArguments = reReplace( Arguments.uriArguments, "^[/]+", "", "ALL" )>
            <cfset var strUrl = "#Variables.APIbaseURL#/#Arguments.uriArguments#">
            <cfif NOT structIsEmpty( Arguments.queryParameters )>
                <cfset var strUrl = Variables.Util.AppendURLTokens( strUrl, queryParameters )>
            </cfif>
            <cfset stRet["endpoint"] = strUrl>

            <cfset var httpResponse = {}>
            <cfhttp url="#strUrl#"
                    username="#Variables.apiKey#"
                    password=""
                    method="PUT"
                    timeout="60"
                    throwonerror="false"
                    result="httpResponse">
                <cfhttpparam type="header"
                             encoded="false"
                             name="Accept"
                             value="application/xml">
                <cfif isDefined("Arguments.xmlContent") AND len( trim( toString( Arguments.xmlContent ) ) ) GT 0>
                    <cfhttpparam type="xml"
                                 value="#trim( toString( Arguments.xmlContent ) )#">
                </cfif>
            </cfhttp>

            <cfset stRet["data"] = (isDefined("httpResponse.fileContent") ? toString( httpResponse.fileContent ) : stRet.data)>
            <cfset stRet["headers"] = (isDefined("httpResponse.responseHeader") ? httpResponse.responseHeader : stRet.headers)>
            <cfset stRet["status"] = (isDefined("httpResponse.statusCode") ? toString( httpResponse.statusCode ) : stRet.status)>

            <cfcatch type="any">
                <!---<cfthrow type="cfRecurly" message="An API error occurred." detail="#cfcatch.message#">--->
                <cfset stRet["error"] = true>
                <cfset stRet["error_message"] = cfcatch.message>
            </cfcatch>
        </cftry>

        <cfreturn stRet>
    </cffunction>

    <cffunction name="delete" access="public" returntype="struct" output="false">
        <cfargument name="uriArguments" type="string" required="true">
        <cfargument name="queryParameters" type="struct" required="false" default="#{}#">

        <cfset var stRet = {
             data = ""
            ,headers = {}
            ,status = "000 Unknown"
            ,endpoint = ""
            ,error = false
            ,error_message = ""
        }>
        <cfset var httpResponse = {}>
        <cftry>
            <cfset Arguments.uriArguments = reReplace( Arguments.uriArguments, "^[/]+", "", "ALL" )>
            <cfset var strUrl = "#Variables.APIbaseURL#/#Arguments.uriArguments#">
            <cfif NOT structIsEmpty( Arguments.queryParameters )>
                <cfset var strUrl = Variables.Util.AppendURLTokens( strUrl, queryParameters )>
            </cfif>
            <cfset stRet["endpoint"] = strUrl>

            <cfset var httpResponse = {}>
            <cfhttp url="#strUrl#"
                    username="#Variables.apiKey#"
                    password=""
                    method="DELETE"
                    timeout="60"
                    throwonerror="false"
                    result="httpResponse">
                <cfhttpparam type="header"
                             encoded="false"
                             name="Accept"
                             value="application/xml">
            </cfhttp>

            <cfset stRet["data"] = (isDefined("httpResponse.fileContent") ? toString( httpResponse.fileContent ) : stRet.data)>
            <cfset stRet["headers"] = (isDefined("httpResponse.responseHeader") ? httpResponse.responseHeader : stRet.headers)>
            <cfset stRet["status"] = (isDefined("httpResponse.statusCode") ? toString( httpResponse.statusCode ) : stRet.status)>

            <cfcatch type="any">
                <!---<cfthrow type="cfRecurly" message="An API error occurred." detail="#cfcatch.message#">--->
                <cfset stRet["error"] = true>
                <cfset stRet["error_message"] = cfcatch.message>
            </cfcatch>
        </cftry>

        <cfreturn stRet>
    </cffunction>
</cfcomponent>