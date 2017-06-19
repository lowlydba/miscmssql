DECLARE AllDatabases CURSOR FOR
SELECT [name] FROM master.dbo.sysdatabases WHERE dbid > 4
 
OPEN AllDatabases
 
DECLARE @DBNameVar NVARCHAR(128),@STATEMENT NVARCHAR(MAX)
 
FETCH NEXT FROM AllDatabases INTO @DBNameVar
WHILE (@@FETCH_STATUS = 0)
BEGIN
PRINT N'--CHECKING DATABASE ' + @DBNameVar
SET @STATEMENT = N'USE [' + @DBNameVar + ']'+ CHAR(13) +';' +CHAR(13)
+ N'
SELECT SO.name
		, ((CONVERT(Numeric(19,6), migs.user_seeks)+CONVERT(Numeric(19,6), migs.unique_compiles))
			*CONVERT(Numeric(19,6), migs.avg_total_user_cost)
			*CONVERT(Numeric(19,6), migs.avg_user_impact/100.0)) AS Impact
		, ''CREATE NONCLUSTERED INDEX IDX_'' + SO.name +''_'' + STUFF (
		(SELECT ''_'' + column_name FROM sys.dm_db_missing_index_columns(mid.index_handle) WHERE column_usage IN (''Equality'',''InEquality'') FOR XML PATH (''''))
		, 1, 1, '''')  + '' ON ['+@DBNameVar+'].'' + schema_name(SO.schema_id) + ''.'' + SO.name COLLATE DATABASE_DEFAULT + '' ( '' + IsNull(mid.equality_columns, '''') + CASE WHEN mid.inequality_columns IS NULL
		THEN ''''
		ELSE CASE WHEN mid.equality_columns IS NULL
		THEN ''''
		ELSE '','' END + mid.inequality_columns END + '' ) '' + CASE WHEN mid.included_columns IS NULL
		THEN ''''
		ELSE ''INCLUDE ('' + mid.included_columns + '')'' END + '';'' AS CreateIndexStatement
		, mid.equality_columns
		, mid.inequality_columns
		, mid.included_columns
	FROM sys.dm_db_missing_index_group_stats AS migs
		INNER JOIN sys.dm_db_missing_index_groups AS mig
			ON migs.group_handle = mig.index_group_handle
		INNER JOIN sys.dm_db_missing_index_details AS mid
			ON mig.index_handle = mid.index_handle
			AND mid.database_id = DB_ID()
		INNER JOIN sys.objects SO WITH (nolock)
			ON mid.OBJECT_ID = SO.OBJECT_ID
	WHERE (migs.group_handle IN
			(
			SELECT TOP (500) group_handle
			FROM sys.dm_db_missing_index_group_stats WITH (nolock)
			ORDER BY ((CONVERT(Numeric(19,6), migs.user_seeks)+CONVERT(Numeric(19,6), migs.unique_compiles))
				*CONVERT(Numeric(19,6), migs.avg_total_user_cost)
				*CONVERT(Numeric(19,6), migs.avg_user_impact/100.0)) DESC))
		AND OBJECTPROPERTY(SO.OBJECT_ID, ''isusertable'')=1
	ORDER BY 2 DESC , 3 DESC' 
 
PRINT @STATEMENT
EXEC SP_EXECUTESQL @STATEMENT
PRINT CHAR(13) + CHAR(13)
FETCH NEXT FROM AllDatabases INTO @DBNameVar
END
 
CLOSE AllDatabases
DEALLOCATE AllDatabases