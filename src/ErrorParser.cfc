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

<cfcomponent displayname="cfRecurly.ErrorParser" hint="Converts recurly API errors into an easily interactable form" output="false">
    <!--- TODO: Implement -J --->
</cfcomponent>

<!---

Error Formats:

<?xml version="1.0" encoding="UTF-8"?> <errors> <error field="billing_info.number" symbol="expired">is expired or has an invalid expiration date</error> </errors>
<?xml version="1.0" encoding="UTF-8"?> <error> <symbol>not_found</symbol> <description lang="en-US">Couldn't find BillingInfo with account_code = test-1</description> </error>
<?xml version="1.0" encoding="UTF-8"?> <errors> <transaction_error> <error_code>declined</error_code> <error_category>soft</error_category> <merchant_message>The customer's bank has declined their card. The customer will need to contact their bank to learn the cause.</merchant_message> <customer_message>Your transaction was declined. Please use a different card or contact your bank.</customer_message> </transaction_error> <error field="billing_info.base" symbol="declined">Your transaction was declined. Please use a different card or contact your bank.</error> <transaction href="https://wysk.recurly.com/v2/transactions/23b7bea421c3ac5d92090649f2a2599b" type="credit_card"> <account href="https://wysk.recurly.com/v2/accounts/test-1"/> <uuid>23b7bea421c3ac5d92090649f2a2599b</uuid> <action>verify</action> <amount_in_cents type="integer">0</amount_in_cents> <tax_in_cents type="integer">0</tax_in_cents> <currency>USD</currency> <status>declined</status> <reference>7482257</reference> <source>billing_info</source> <recurring type="boolean">false</recurring> <test type="boolean">true</test> <voidable type="boolean">false</voidable> <refundable type="boolean">false</refundable> <transaction_error> <error_code>declined</error_code> <error_category>soft</error_category> <merchant_message>The customer's bank has declined their card. The customer will need to contact their bank to learn the cause.</merchant_message> <customer_message>Your transaction was declined. Please use a different card or contact your bank.</customer_message> </transaction_error> <cvv_result code="" nil="nil"></cvv_result> <avs_result code="" nil="nil"></avs_result> <avs_result_street nil="nil"></avs_result_street> <avs_result_postal nil="nil"></avs_result_postal> <created_at type="datetime">2013-11-11T20:56:19Z</created_at> <details> <account> <account_code>test-1</account_code> <first_name>Jennifer</first_name> <last_name>Gohlke</last_name> <company nil="nil"></company> <email>jenny.gohlke@gmail.com</email> <billing_info type="credit_card"> <first_name>Jennifer</first_name> <last_name>Gohlke</last_name> <address1>2901 Country Club Dr</address1> <address2 nil="nil"></address2> <city>Pearland</city> <state>TX</state> <zip>77581</zip> <country>US</country> <phone>832-335-6900</phone> <vat_number nil="nil"></vat_number> <card_type>Visa</card_type> <year type="integer">2016</year> <month type="integer">4</month> <first_six>434258</first_six> <last_four>5364</last_four> </billing_info> </account> </details> </transaction> </errors>
--->