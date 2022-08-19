(:Summary:)
(:Объединение двух последовательностей.:)
(:Params:)
(:Param $firstSeq - главная последовательность:)
(:Param $secondSeq - вторая последовательность:)
(:Param $keyFunction - функция выборки ключа для объединения:)
(:Usage~
:	let $orgs := oda:xquery-doc('H:1D62386A9215A42/D:WORK/D:1D465EBA7DB470F/C:1D465F3CB1FBFBB/I:Pack','PACK/OBJECT')/OBJECT
:	return local:Join((PACK/OBJECT), $orgs, function($x) { ($x/Org,$x)[1]/(@INN,@Number) })
:)
declare function local:Join($firstSeq as element()*, $secondSeq as element()*, $keyFunction as function(*)) {
	let $srcWithKey := $firstSeq/functx:add-or-update-attributes(.,xs:QName('__FOR_GROUPBY_SYSTEM'), 1)	
 	for $a in ($srcWithKey, $secondSeq)
	let $name := fn:node-name($a)
	group by data($keyFunction($a))
	let $joinableEl := $a[not(@__FOR_GROUPBY_SYSTEM)][last()]
		for $b in $a[@__FOR_GROUPBY_SYSTEM]
		return element { $name }  {			
			(
				if($joinableEl) 
				then functx:copy-attributes($joinableEl, $b) 
				else $b
			)/(@*[name() != '__FOR_GROUPBY_SYSTEM'],*),
			$b/*,
			$joinableEl/*
		}
};
(:Summary:)
(:Объединение двух последовательностей.:)
(:Params:)
(:Param $firstSeq - главная последовательность:)
(:Param $secondSeq - вторая последовательность:)
(:Param $key - функция выборки ключа для объединения:)
(:Usage~
:	let $orgs := oda:xquery-doc('H:1D62386A9215A42/D:WORK/D:1D465EBA7DB470F/C:1D465F3CB1FBFBB/I:Pack','PACK/OBJECT')/OBJECT
:	return local:JoinByKeyName((PACK/OBJECT), $orgs, "INN")
:)
declare function local:JoinByKeyName($firstSeq as element()*, $secondSeq as element()*, $key as xs:string) {
	let $srcWithKey := $firstSeq/functx:add-or-update-attributes(.,xs:QName('__FOR_GROUPBY_SYSTEM'), 1)	
 	for $a in ($srcWithKey, $secondSeq)
	let $name := fn:node-name($a)
	group by data(functx:dynamic-path($a, concat("@",$key)))
	let $joinableEl := $a[not(@__FOR_GROUPBY_SYSTEM)][last()]
		for $b in $a[@__FOR_GROUPBY_SYSTEM]
		return element { $name }  {			
			(
				if($joinableEl) 
				then functx:copy-attributes($joinableEl, $b) 
				else $b
			)/(@*[name() != '__FOR_GROUPBY_SYSTEM']),
			$b/*,
			$joinableEl/*
		}
};


(:Summary:)
(:Выборка пакетов из класса по датам.:)
(:Params:)
(:Param $path - полный путь до класса:)
(:Param $dateBegin - дата начала поиска пакетов:)
(:Param $dateEnd - дата конца поиска пакетов:)
(:Param $fieldName - поле даты по которому пакеты в классе:)
(:Usage local:GetPackByDate('oda://H:this/D:1D465EBA7DB470F/C:1D48C73740A0E7F/I:ActualStatus',$dateBegin,$dateEnd, "OpenPer"):)
declare function local:GetPackByDate($path as xs:string,$dateBegin as xs:dateTime,$dateEnd as xs:dateTime, $fieldName as xs:string) element()*
{
	let $year-diff := year-from-dateTime($dateEnd) - year-from-dateTime($dateBegin)
	let $month-diff := month-from-dateTime($dateEnd) - month-from-dateTime($dateBegin)
	let $diff := (($year-diff * 12) + $month-diff)
	let $Periods :=
		for $n in 0 to $diff
		return xs:dateTime(functx:add-months($dateBegin, +$n))
	let $ShortDateTimePeriods:= string-join(format-dateTime($Periods,'yyyy-mm'),';')
	let $pack := oda:xquery-doc(concat($path,'|',$ShortDateTimePeriods),concat('PACK/OBJECT[oda:left(@', $fieldName, ',19) >="',$dateBegin,'" and oda:left(@', $fieldName ,',19) <="',$dateEnd,'"]'))/OBJECT
	return $pack
};
