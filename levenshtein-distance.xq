(:Summary:)
(:Лучшее совпадение для строки из коллекции:)
(:Params:)
(:Param $string - значение:)
(:Param $stringSource - источник строк:)
(:Usage~
:	let $testString := 'Тандер  Архангельский филиал, АО'
:	let $testDataSource := ('Другое','Тандер  "Архангельский филиал", АО','Тандер')
:	return local:closest-value($testString, $testDataSource)
:)
declare function local:closest-value($string as xs:string, $stringSource as xs:string*)
{
	let $result :=
		for $a in $stringSource
		let $distance:= local:levenshtein-distance($a,$string)
		order by $distance
		return element X{
			attribute value {$a},
			attribute percent {concat(oda:num(1 - ($distance div max( (string-length($string),string-length($a)))),2) *100,'%')},
			attribute distance {$distance }
		}
	return element result{
		element bestChoice{oda:first($result)},
		element DataSource {$result}
	}
};

(:Summary:)
(:Расстояние Левенштейна:)
(:Params:)
(:Param $string1 - первая строка:)
(:Param $string2 - вторая строка:)
(:Usage~
:	local:levenshtein-distance('Тандер  Архангельский филиал, АО', 'Тандер')
:)
declare function local:levenshtein-distance($string1 as xs:string?, $string2 as xs:string?)
as xs:integer
{
  if ( fn:min( (fn:string-length($string1), fn:string-length($string2)) ) = 0 )
  then 
    fn:max((fn:string-length($string1), fn:string-length($string2)))
  else
    local:_levenshtein-distance(
                        fn:string-to-codepoints($string1),
                        fn:string-to-codepoints($string2),
                        fn:string-length($string1),
                        fn:string-length($string2),
                       (1, 0, 1),
                       2
  ) 
};

declare function local:_levenshtein-distance(
                                              $chars1 as xs:integer*, 
                                              $chars2 as xs:integer*, 
                                              $length1 as xs:integer, 
                                              $length2 as xs:integer,
                                              $lastDiag as xs:integer*, 
                                              $total as xs:integer)
as xs:integer 
{ 
  let $shift := if ($total > $length2) then ($total - ($length2 + 1)) else 0 
  let $diag := 
    for $i in (fn:max((0, $total - $length2)) to fn:min(($total, $length1))) 
  let $j := $total - $i let $d := ($i - $shift) * 2 
  return ( 
    if ($j lt $length2) then 
      $lastDiag[$d - 1]
    else () ,
    if ($i = 0) then $j 
    else if ($j = 0) then $i 
    else fn:min(($lastDiag[$d - 1] + 1, 
                      $lastDiag[$d + 1] + 1,
                      $lastDiag[$d] + (if ($chars1[$i] = $chars2[$j]) then 0 else 1)
                    ))
    )
  return
    if ($total = $length1 + $length2) then fn:exactly-one($diag)
    else local:_levenshtein-distance($chars1, $chars2, $length1, $length2, $diag, $total + 1) 
};

(: EXAMPLE :)
let $testString := 'Тандер  Архангельский филиал, АО'
let $testDataSource := ('Другое','Тандер  "Архангельский филиал", АО','Тандер')

let $result :=
	for $a in $testDataSource
	let $distance:= local:levenshtein-distance($a,$testString)
	order by $distance
	return element X{
		attribute value {$a},
		attribute percent {concat(oda:num(1 - ($distance div max( (string-length($testString),string-length($a)))),2) *100,'%')},
		attribute distance {$distance }
	}
return element result{
	element bestChoice{oda:first($result)},
	element DataSource {$result}
}