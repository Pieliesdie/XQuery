(:Summary:)
(:Поиск изменений в объектах:)
(:Params:)
(:Param $path - полный путь до объекта:)
(:Usage~
:	local:object-history('H:1D670A1783307C2/D:WORK/D:1D71734A22F0A18/C:1D7246A8CE6C3D9/O:1D7873752C36BDA')
:)
declare function local:object-history($path as xs:string)
{
(:
	Get all object's changes with current state
	return
	DATASET with 
		N nodes <History>
		1 node <Current>
:)
(:#region Variables:)
(:Full id to object:)
let $ObjectId := $path
(:Date mask YYYY-MM-DD:)
let $mask := '*'
(: ValueList=
	1=изменение объекта
	
	//script doesn't support
	2=удаление объекта 
	4=изменение класса
	8=изменение/удаление файла:)
let $types := '1'
(:#end region Variables:)


let $hostId := substring-before(substring-after($ObjectId,'H:'),'/') 
let $Users := 
	for $user in oda:xquery-doc(concat('oda://H:',$hostId,'/D:SYSTEM/C:000000000000020/I:Pack'),'*')/PACK/OBJECT
	return element User{
		$user/@oid,
		$user/@name
	}
let $objectOid := substring-after($ObjectId,'O:')
let $backupInfo:= xqilla:parse-xml(oda:command(concat('get_backups_info?id=',$ObjectId,'&amp;mask=',$mask,'&amp;types=',$types)))

let $History:= 
	for $change in $backupInfo/DATASET/DATA/R
	where $change/@o = $objectOid
	return element History{
		attribute ChangedByUser {$Users[@oid = $change/@u]/@name},
		$change/(@d,@t,@n,@u),
		switch($types)
		case '1'
			return xqilla:parse-xml(oda:command(concat('get_backup_update_object?id=',$ObjectId,'&amp;d=',oda:left($change/@d,10),'&amp;i=',$change/@i)))
		(:Your additional cases here:)
		default return ()
	}
let $now := oda:now()
let $currentObject := oda:xquery-doc(($ObjectId),'*')/OBJECT
let $Current:= 
	element Current {
		attribute ChangedByUser {$Users[@oid = $currentObject/@user]/@name},
		attribute d {format-dateTime(oda:now(),'yyyy-MM-dd')},
		attribute t {format-dateTime(oda:now(),'hh:mm:ss')},
		attribute n {$currentObject/@name},
		$currentObject
	}
let $result:= 
	element DATASET {
		($History,$Current)
	}
	
(:Your Filters here:)
return $result
};