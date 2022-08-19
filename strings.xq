module namespace str = "oda";
declare default function namespace "oda";
(:Summary:)
(:Вставляет параметры в plaint text запроса:)
(:Params:)
(:Param $string - исходный запрос с параметрами:)
(:Param $name - имя параметра:)
(:Param $value - значение параметра:)
(:Usage 
let $link := 'H:this/D:WORK/D:1D465EBA7DB470F/D:1CDA7834ECABDD2/C:1CA61E90FB736A1/O:1D7FCBFE06DDB9D'
let $query := oda:xquery-doc($link,'*')/OBJECT/XQ/oda:cdata()
let $query := local:insertParameter($query, 'dateType', 'Квартал')
:)
declare function insertParameter($query as xs:string, $name as xs:string, $value as xs:string) as xs:string {
	fn:replace($query, fn:concat("\[#",$name,"#\]"),$value)
};

(:Summary:)
(:Проверяет строку на непустоту.:)
(:Params:)
(:Param $string - исходная строка:)
(:Usage local:NotEmpty("test_string"):)
declare function NotEmpty($source as xs:string) as xs:boolean
{
	if (fn:string-length($source)>0) then fn:true() else fn:false()
};

(:Summary:)
(:Преобразует значения объектов в строки на основе указанных форматов и вставляет их в другую строку.:)
(:Params:)
(:Param $string - исходная строка с токенами подстановки в виде {N}:)
(:Param $params - значения для подстановки:)
(:Usage local:format('PACK/OBJECT[@oid = "{0}"]', /OBJECT/@oid):)
declare function format($string as xs:string, $params as xs:string*) as xs:string {
	if(fn:count($params) = 0 ) then $string else	
	let $newString := fn:replace($string, fn:concat('\{',fn:count($params) - 1,'\}'), xs:string($params[fn:last()]))
	return format($newString, $params[fn:position() != fn:last()])
};
