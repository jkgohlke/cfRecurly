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
                <cfset var strUrl = AppendURLTokens( strUrl, queryParameters )>
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
                <cfset var strUrl = AppendURLTokens( strUrl, queryParameters )>
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
                <cfset var strUrl = AppendURLTokens( strUrl, queryParameters )>
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
                <cfset var strUrl = AppendURLTokens( strUrl, queryParameters )>
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

    <cffunction name="StructExtend" access="public" returntype="struct" output="false">
        <cfargument name="structFrame" type="struct" required="true">
        <cfargument name="structExtended" type="struct" required="true">

        <cfset var retStruct = duplicate( Arguments.structFrame )>
        <cfset StructAppendDeep( retStruct, Arguments.structExtended, true )>
        <cfreturn retStruct>
    </cffunction>

    <cffunction name="StructAppendDeep" access="public" returntype="struct" output="false">
        <cfargument name="stLeft" type="struct" required="true">
        <cfargument name="stRight" type="struct" required="true">
        <cfargument name="bOverwrite" type="boolean" required="false" default="true">

        <cfset var idxKeyName = "">
        <cfloop collection="#Arguments.stRight#" item="idxKeyName">
            <cfif StructKeyExists(Arguments.stLeft, idxKeyName)>
                <cfif IsStruct(Arguments.stLeft[idxKeyName]) AND IsStruct(Arguments.stRight[idxKeyName])>
                    <cfset StructAppendDeep(Arguments.stLeft[idxKeyName], Arguments.stRight[idxKeyName], Arguments.bOverwrite)>
                <cfelseif Arguments.bOverwrite>
                    <cfset Arguments.stLeft[idxKeyName] = Arguments.stRight[idxKeyName]>
                </cfif>
            <cfelse>
                <cfset Arguments.stLeft[idxKeyName] = Arguments.stRight[idxKeyName]>
            </cfif>
        </cfloop>

        <cfreturn Arguments.stLeft>
    </cffunction>

    <cffunction name="AppendURLTokens" access="private" returntype="string" output="false">
        <cfargument name="url" type="string" required="true">
        <cfargument name="params" type="struct" required="true">

        <!--- TODO: This is kinda hacky, maybe clean it up when we have time... -J --->
        <cfset var split = javacast( "string", Arguments.url ).split( "[?]" )>
        <cfset Arguments.url = split[ 1 ]>
        <cfset queryString = "">
        <cfif arraylen( split ) GT 1>
            <cfset queryString = split[ 2 ]>
        </cfif>
        <cfset Arguments.params = StructExtend( DeparamQueryString( queryString ), Arguments.params )>

        <cfset var addTokens = "">
        <cfset var lstParamNames = structKeyList( Arguments.params )>
        <cfset var lastParamName = listLast( lstParamNames )>
        <cfloop list="#lstParamNames#" index="paramName">
            <cfset var separator = "&">
            <cfif lastParamName EQ paramName>
                <cfset separator = "">
            </cfif>
            <cfset addTokens = addTokens & paramName & "=" & Arguments.params[ paramName ] & separator>
        </cfloop>

        <cfif len( addTokens ) GT 0>
            <cfset var tokenSeparator = "?">
            <cfif find( "?", Arguments.url ) NEQ 0>
                <cfset tokenSeparator = "&">
            </cfif>
            <cfset var hash = "">
            <cfset var hashIndex = find( "##", Arguments.url )>
            <cfif hashIndex NEQ 0>
                <cfset hash = mid( Arguments.url, hashIndex, len( Arguments.url ) - hashIndex + 1 )>
                <cfset Arguments.url = mid( Arguments.url, 1, hashIndex - 1 )>
            </cfif>
            <cfset Arguments.url = Arguments.url & tokenSeparator & addTokens & hash>
        </cfif>

        <cfreturn Arguments.url>
    </cffunction>

    <cffunction name="DeparamQueryString" access="public" returntype="struct" output="false">
        <cfargument name="queryString" type="string" required="true">

        <cfif not len( trim( Arguments.queryString ) )>
            <cfreturn {}>
        </cfif>

        <cfset var retStruct = {}>

        <cfset var queryParam = "">
        <cfloop list="#Arguments.queryString#" delimiters="&" index="queryParam">
            <cfif len( queryParam ) GT 0>
                <cfset retStruct[ listFirst( queryParam, "=" ) ] = listLast( queryParam, "=" )>
            </cfif>
        </cfloop>

        <cfreturn retStruct>
    </cffunction>

    <cffunction name="FindWithRegex" access="public" returntype="array" output="false">
        <cfargument name="Regex" type="string" required="true">
        <cfargument name="ParsingString" type="string" required="true">
        <cfargument name="FindAll" type="boolean" required="false" default="false">

        <cfset objPattern = CreateObject( "java", "java.util.regex.Pattern" )>
        <cfset regexPattern = objPattern.compile( Arguments.Regex )>
        <cfset regexMatcher = regexPattern.matcher( Arguments.ParsingString )>
        <cfif Arguments.FindAll>
            <cfset retArray = ArrayNew( 2 )>
            <cfset numFound = 0>
            <cfloop condition="regexMatcher.find()">
                <cfset numFound++ >
                <cfset totalGroups = regexMatcher.groupCount( )>
                <cfset var idx = 0>
                <cfloop from="0" to="#totalGroups#" step="1" index="idx">
                    <cfset groupFound = regexMatcher.group( JavaCast( "int", idx ) )>
                    <cfif isDefined("groupFound")>
                        <cfset retArray[numFound][idx + 1] = groupFound>
                    <cfelse>
                        <cfset retArray[numFound][idx + 1] = "">
                    </cfif>
                </cfloop>
            </cfloop>
            <cfreturn retArray>
        <cfelse>
            <cfset found = regexMatcher.find( )>
            <cfif found IS TRUE or found IS "YES">
                <cfset totalGroups = regexMatcher.groupCount( )>
                <cfset retArray = ArrayNew( 1 )>
                    <cfset var idx = 0>
                    <cfloop from="0" to="#totalGroups#" step="1" index="idx">
                        <cfset groupFound = regexMatcher.group( JavaCast( "int", idx ) )>
                        <cfif isDefined("groupFound")>
                            <cfset retArray[idx + 1] = groupFound>
                        <cfelse>
                            <cfset retArray[idx + 1] = "">
                        </cfif>
                    </cfloop>
                <cfreturn retArray>
            </cfif>
        </cfif>

        <cfreturn []>
    </cffunction>

    <cffunction name="GetIsoTimeString" access="public" returntype="array" output="false">
        <cfargument name="dtOriginal" type="date" required="true">
        <cfargument name="bConvertToUTC" type="date" required="false">

        <cfif Arguments.bConvertToUTC>
            <cfset Arguments.dtOriginal = dateConvert( "local2utc", Arguments.dtOriginal )>
        </cfif>

        <cfreturn ( dateFormat( Arguments.dtOriginal, "yyyy-mm-dd" ) & "T" & timeFormat( Arguments.dtOriginal, "HH:mm:ss" ) & "Z" )>
    </cffunction>
</cfcomponent>