
/*
--------------------------------------------------------------------------------------------------------
Script to generate DROP/ADD queries for Foreign Keys, Primary Keys and Default constraints of a DB/Table
--------------------------------------------------------------------------------------------------------
Author	:	Jayakumaur R
Date	:	2014-04-25 12:01:02.457
Version	:	v1.1
Exec	:	-
Notes	:	By default, the queries are generated for all foreign keys/primary keys/default constraints 
in the database. If you need to do so for a particular table, replace 'table_name' with the respective
table name in the WHERE clause of the particular query.
*/


/********************************************FOREIGN KEY*******************************************************/

---------------------------------------------
--ALTER TABLE DROP FOREIGN CONSTRAINT Queries
---------------------------------------------
SELECT DISTINCT
 'ALTER TABLE '+QUOTENAME(OBJECT_SCHEMA_NAME(fkeyid))+'.'+QUOTENAME(OBJECT_NAME(fkeyid))+
' DROP CONSTRAINT '+QUOTENAME(OBJECT_NAME(constid))
AS Drop_Foreign_Key_Constraint_Query
FROM sys.sysforeignkeys sfk
/*Include below statement for generating queries for a particular table*/
--WHERE fkeyid=OBJECT_ID('table_name')


------------------------------------------------
--ALTER TABLE CREATE FOREIGN CONSTRAINT Queries
------------------------------------------------

--Obtaining the necessary info from the sys tables
SELECT 
 constid,QUOTENAME(OBJECT_NAME(constid)) as constraint_name
,CASE WHEN fk.is_not_trusted=1 THEN 'WITH NOCHECK' ELSE 'WITH CHECK' END as trusted_status
,QUOTENAME(OBJECT_SCHEMA_NAME(fkeyid))+'.'+QUOTENAME(OBJECT_NAME(fkeyid)) AS fk_table,QUOTENAME(c1.name) AS fk_col
,QUOTENAME(OBJECT_SCHEMA_NAME(rkeyid))+'.'+QUOTENAME(OBJECT_NAME(rkeyid)) AS rk_table,QUOTENAME(c2.name) AS rk_col
,CASE WHEN fk.delete_referential_action=1 AND fk.delete_referential_action_desc='CASCADE' THEN 'ON DELETE CASCADE ' ELSE '' END AS delete_cascade
,CASE WHEN fk.update_referential_action=1 AND fk.update_referential_action_desc='CASCADE' THEN 'ON UPDATE CASCADE ' ELSE '' END AS update_cascade
,CASE WHEN fk.is_disabled=1 THEN 'NOCHECK' ELSE 'CHECK' END AS check_status
--,sysfk.*,fk.* 
INTO #temp_fk
FROM sys.sysforeignkeys sysfk
INNER JOIN sys.foreign_keys fk ON sysfk.constid=fk.object_id
INNER JOIN sys.columns c1 ON sysfk.fkeyid=c1.object_id and sysfk.fkey=c1.column_id
INNER JOIN sys.columns c2 ON sysfk.rkeyid=c2.object_id and sysfk.rkey=c2.column_id
/*Include below statement for generating queries for a particular table*/
--WHERE fkeyid=OBJECT_ID('table_name')
ORDER BY constid,sysfk.keyno

--building the column list for foreign/primary key tables
;WITH cte
AS
(
	SELECT DISTINCT
	constraint_name,trusted_status
	,fk_table
	,SUBSTRING((SELECT ','+fk_col FROM #temp_fk WHERE constid=c.constid FOR XML PATH('')),2,99999) AS fk_col_list
	,rk_table
	,SUBSTRING((SELECT ','+rk_col FROM #temp_fk WHERE constid=c.constid FOR XML PATH('')),2,99999) AS rk_col_list
	,check_status
	,delete_cascade,update_cascade
	FROM 
	#temp_fk c
)
--forming the ADD CONSTRAINT query
SELECT 
'ALTER TABLE '+fk_table
+' '+trusted_status
+' ADD CONSTRAINT '+constraint_name
+' FOREIGN KEY('+fk_col_list+') REFERENCES '
+rk_table+'('+rk_col_list+')'
+' '+delete_cascade+update_cascade+';'
+' ALTER TABLE '+fk_table+' '+check_status+' CONSTRAINT '+constraint_name
AS Add_Foreign_Key_Constraint_Query
FROM cte

--dropping the temp tables
DROP TABLE #temp_fk


/*******************************************PRIMARY KEY******************************************************/

-------------------------------------------------
--ALTER TABLE DROP PRIMARY KEY CONSTRAINT Queries
-------------------------------------------------
SELECT DISTINCT
'ALTER TABLE '+QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id))+'.'+QUOTENAME(OBJECT_NAME(parent_object_id))+' DROP CONSTRAINT '+QUOTENAME(name)
AS Drop_Primary_Key_Constraint_Query
FROM sys.key_constraints skc
WHERE type='PK'
/*Include below statement for generating queries for a particular table*/
--AND parent_object_id=object_id('table_name')


---------------------------------------------------
--ALTER TABLE CREATE PRIMARY KEY CONSTRAINT Queries
---------------------------------------------------
SELECT 
 QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id))+'.'+QUOTENAME(OBJECT_NAME(parent_object_id)) AS pk_table--PK table name
,skc.object_id AS constid
,QUOTENAME(skc.name) AS constraint_name--PK name
,QUOTENAME(iskcu.column_name) + CASE WHEN sic.is_descending_key=1 THEN ' DESC' ELSE ' ASC' END  AS pk_col
,iskcu.ordinal_position
,CASE WHEN unique_index_id=1 THEN 'UNIQUE' ELSE '' END as index_unique_type
,si.name AS index_name
,si.type_desc AS index_type
,QUOTENAME(fg.name) AS filegroup_name
,'WITH('
+' PAD_INDEX = '+CASE WHEN si.is_padded=0 THEN 'OFF' ELSE 'ON' END +','
+' IGNORE_DUP_KEY = '+CASE WHEN si.ignore_dup_key=0 THEN 'OFF' ELSE 'ON' END +','
+' ALLOW_ROW_LOCKS = '+CASE WHEN si.allow_row_locks=0 THEN 'OFF' ELSE 'ON' END +','
+' ALLOW_PAGE_LOCKS = '+CASE WHEN si.allow_page_locks=0 THEN 'OFF' ELSE 'ON' END 
+')' AS index_property
--,*
INTO #temp_pk
FROM sys.key_constraints skc
INNER JOIN information_schema.key_column_usage iskcu ON skc.name=iskcu.constraint_name
INNER JOIN sys.indexes si ON si.object_id=skc.parent_object_id and si.is_primary_key=1
INNER JOIN sys.index_columns sic ON si.object_id=sic.object_id and si.index_id=sic.index_id 
INNER JOIN sys.columns c ON sic.object_id=c.object_id AND sic.column_id=c.column_id 
INNER JOIN sys.filegroups fg ON si.data_space_id=fg.data_space_id
WHERE 
skc.type='PK' 
AND iskcu.column_name=c.name 
/*Include below statement for generating queries for a particular table*/
--AND skc.parent_object_id= object_id('table_name')
ORDER BY skc.parent_object_id,skc.name,ordinal_position

;WITH cte
AS
(
	SELECT 
		pk_table
		,constraint_name
		,index_type
		,SUBSTRING((SELECT ','+pk_col FROM #temp_pk WHERE constid=t.constid FOR XML PATH('')),2,99999) AS pk_col_list
		,index_unique_type
		,filegroup_name
		,index_property
	FROM #temp_pk t
)
--forming the ADD CONSTRAINT query
SELECT DISTINCT
'ALTER TABLE '+pk_table
+' ADD CONSTRAINT '+constraint_name
+' PRIMARY KEY '+CAST(index_type COLLATE database_default AS VARCHAR(100))
+' ('+pk_col_list+')'
+index_property
+' ON '+filegroup_name+''
AS Create_Primary_Key_Constraint_Query
FROM cte

--dropping the temp tables
DROP TABLE #temp_pk


/*****************************************DEFAULT CONSTRAINT****************************************************/

---------------------------------------------
--ALTER TABLE DROP DEFAULT CONSTRAINT Queries
---------------------------------------------
SELECT 
'ALTER TABLE '+QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id))+'.'+QUOTENAME(object_name(parent_object_id))
+' DROP CONSTRAINT '+QUOTENAME(sdc.name)+''
AS Drop_Default_Constraint_Query
FROM sys.default_constraints sdc
/*Include below statement for generating queries for a particular table*/
--WHERE parent_object_id=object_id('table_name')


---------------------------------------------
--ALTER TABLE CREATE DEFAULT CONSTRAINT Queries
---------------------------------------------
select 
'ALTER TABLE '+QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id))+'.'+QUOTENAME(OBJECT_NAME(parent_object_id))
+' ADD CONSTRAINT '+QUOTENAME(sdc.name)+' DEFAULT '+definition+' FOR '+QUOTENAME(c.name)+''
AS Add_Default_Constraint_Query
FROM sys.default_constraints sdc
inner join sys.columns c ON sdc.parent_object_id=c.object_id and sdc.parent_column_id=c.column_id
/*Include below statement for generating queries for a particular table*/
--WHERE parent_object_id=object_id('table_name')