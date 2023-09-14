query -> object

object -> "{" _ "}" {% function(d) { return {}; } %}  |
	"{" _ pair (_ "," _ pair):* _ "}"

operator_expression -> "{" _ operator_to_value _ "}"
aggregate_expression -> "{" _ aggregate_op _ "}"
	
pair -> field_to_value | operator_to_value	

field_to_value -> field _ ":" _ value
operator_to_value -> comparison_op | logical_op | element_op | eval_op | array_op | comment

comparison_op -> comparison_op_eq | comparison_op_gt | comparison_op_gte | comparison_op_in
| comparison_op_lt | comparison_op_lte | comparison_op_ne | comparison_op_nin

aggregate_op -> (aggregate_keyword | quote aggregate_keyword quote | quote2 aggregate_keyword quote2) _ ":" _ value

logical_op -> logical_op_and | logical_op_nor | logical_op_not | logical_op_or
element_op -> element_op_exists | element_op_type
eval_op ->  eval_op_expr | eval_op_mod | eval_op_regex | eval_op_text | eval_op_where | eval_op_jsonSchema
array_op -> array_op_all | array_op_elemMatch | array_op_size
comment -> ("$comment" | quote "$comment" quote | quote2 "$comment" quote2)  _ ":" _ string

comparison_op_eq -> ("$eq" | quote "$eq" quote | quote2 "$eq" quote2) _ ":" _ value
comparison_op_gt  -> ("$gt" | quote "$gt" quote | quote2 "$gt" quote2) _ ":" _ (num | string)
comparison_op_gte -> ("$gte" | quote "$gte" quote | quote2 "$gte" quote2) _ ":" _ (num | string)
comparison_op_in -> ("$in" | quote "$in" quote | quote2 "$in" quote2) _ ":" _ array
comparison_op_lt -> ("$lt" | quote "$lt" quote | quote2 "$lt" quote2) _ ":" _ (num | string)
comparison_op_lte -> ("$lte" | quote "$lte" quote | quote2 "$lte" quote2) _ ":" _ (num | string)
comparison_op_ne -> ("$ne" | quote "$ne" quote | quote2 "$ne" quote2) _ ":" _ value
comparison_op_nin -> ("$nin" | quote "$nin" quote | quote2 "$nin" quote2) _ ":" _ array

logical_op_and -> ("$and" | quote "$and" quote | quote2 "$and" quote2) _ ":" _ array
logical_op_not -> ("$not" | quote "$not" quote | quote2 "$not" quote2) _ ":" _ operator_expression
logical_op_nor -> ("$nor" | quote "$nor" quote | quote2 "$nor" quote2) _ ":" _ array
logical_op_or -> ("$or" | quote "$or" quote | quote2 "$or" quote2) _ ":" _ array

element_op_exists -> ("$exists" | quote "$exists" quote | quote2 "$exists" quote2) _ ":" _ boolean
element_op_type -> ("$type" | quote "$type" quote | quote2 "$type" quote2) _ ":" _ (num | array_of_string | array_of_num | string)

array_op_all -> ("$all" | quote "$all" quote | quote2 "$all" quote2) _ ":" _ array
array_op_elemMatch -> ("$elemMatch" | quote "$elemMatch" quote | quote2 "$elemMatch" quote2) _ ":" _ object
array_op_size -> ("$size" | quote "$size" quote | quote2 "$size" quote2) _ ":" _ num

eval_op_expr -> ("$expr" | quote "$expr" quote | quote2 "$expr" quote2) _ ":" _ aggregate_expression
eval_op_mod -> ("$mod" | quote "$mod" quote | quote2 "$mod" quote2) _ ":" _ array_of_num
eval_op_regex -> ("$regex" | quote "$regex" quote | quote2 "$regex" quote2) _ ":" _ regex_pattern ( _ "," _ "$options" _ ":" _  "'" alphabet:+ "'" ):?
eval_op_text -> ("$text" | quote "$text" quote | quote2 "$text" quote2) _ ":" _ "{" _ text_params  _ "}"

#where is not checked
eval_op_where -> ("$where" | quote "$where" quote | quote2 "$where" quote2) _ ":" _ code
eval_op_jsonSchema -> ("$jsonSchema" | quote "$jsonSchema" quote | quote2 "$jsonSchema" quote2) _ ":" _ object

code -> "function" _ "(" _ (key ( "," _ key):*):? _ ")" _ "{" .:* "}" | string

field -> id | key

value ->
	string | num | object | array | boolean | "null" | object_lit

array -> "[" _ (value ( _ "," _ value):*):? _ "]"

array_of_primitives -> array_of_string | array_of_bool | array_of_num

array_of_string -> "[" _ (string ( _ "," _ string):*):? _ "]"
array_of_num -> "[" _ (num ("," _ num):*):? _ "]"
array_of_bool -> "[" _ (boolean ( _ "," _ boolean):*):?  _ "]"

string -> quote _ lit _ quote | quote2 _ lit _ quote2
id -> quote _ key_lit _ quote | quote2 _ key_lit _ quote2

key -> alpha_numeric:+

key_lit -> [^\\"\\\$']:+
lit -> ("\\" [\"bfnrt\/\\] | "\\u" [a-fA-F0-9] [a-fA-F0-9] [a-fA-F0-9] [a-fA-F0-9] | [^"\\]):*
simple_lit -> alphabet:+
object_lit -> "new ":? _ simple_lit "(" .:* ")" 

regex_pattern -> "/" .:* "/" alpha_numeric:*:? | "'" .:* "'"
text_params -> "$search" _ ":" _ string _ "," _ "$language" _ ":" _ string _ "," _
    "$caseSensitive" _ ":" _ boolean _ "," _ "$diacriticSensitive" _ ":" _ boolean


quote -> "\"" 
quote2 -> "'"

alpha_numeric -> [a-zA-Z0-9_]
alphabet -> [a-zA-Z]
num -> "-":? ("0" | [1-9] [0-9]:* ) ("." [0-9]:+ ):? ( [eE] [+-]:? [0-9]:+):?
boolean -> "true" | "false"

_+ -> [\s]:+ {% function(d) {return null } %}
_ -> [\s]:*     {% function(d) {return null } %}


aggregate_keyword -> "$abs" |
"$add" |
"$addToSet" |
"$allElementsTrue" |
"$and" |
"$anyElementTrue" |
"$arrayElemAt" |
"$arrayToObject" |
"$avg" |
"$cmp" |
"$concat" |
"$concatArrays" |
"$cond" |
"$dateFromParts" |
"$dateToParts" |
"$dateFromString" |
"$dateToString" |
"$dayOfMonth" |
"$dayOfWeek" |
"$dayOfYear" |
"$divide" |
"$eq" |
"$exp" |
"$filter" |
"$first" |
"$floor" |
"$gt" |
"$gte" |
"$hour" |
"$ifNull" |
"$in" |
"$indexOfArray" |
"$indexOfBytes" |
"$indexOfCP" |
"$isArray" |
"$isoDayOfWeek" |
"$isoWeek" |
"$isoWeekYear" |
"$last" |
"$let" |
"$literal" |
"$ln" |
"$log" |
"$log10" |
"$lt" |
"$lte" |
"$ltrim" |
"$map" |
"$max" |
"$mergeObjects" |
"$meta" |
"$min" |
"$millisecond" |
"$minute" |
"$mod" |
"$month" |
"$multiply" |
"$ne" |
"$not" |
"$objectToArray" |
"$or" |
"$pow" |
"$push" |
"$range" |
"$reduce" |
"$reverseArray" |
"$rtrim" |
"$second" |
"$setDifference" |
"$setEquals" |
"$setIntersection" |
"$setIsSubset" |
"$setUnion" |
"$size" |
"$slice" |
"$split" |
"$sqrt" |
"$stdDevPop" |
"$stdDevSamp" |
"$strcasecmp" |
"$strLenBytes" |
"$strLenCP" |
"$substr" |
"$substrBytes" |
"$substrCP" |
"$subtract" |
"$sum" |
"$switch" |
"$toLower" |
"$toUpper" |
"$trim" |
"$trunc" |
"$type" |
"$week" |
"$year" 