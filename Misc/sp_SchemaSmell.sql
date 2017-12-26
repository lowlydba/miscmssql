/* TO DO: 
* Get more specific about ideal time formats (#1)
*/

IF OBJECT_ID(N'tempdb..#results') IS NOT NULL
DROP TABLE #results
GO

CREATE TABLE #results (
[ID] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
[check_num] INT NOT NULL,
[check_type] NVARCHAR(50) NOT NULL,
[obj_type] SYSNAME NOT NULL,
[obj_name] SYSNAME NOT NULL,
[col_name] SYSNAME NULL,
[message] NVARCHAR(250) NULL,
[ref_link] NVARCHAR(500) NULL);

INSERT INTO #results
SELECT '0', 'Let''s do this', 'Vroom, vroom', 'Off to the races!', 'Ready, set, go!', 'Last Updated 12/20/2017', 'www.lowlydba.com';

/* Check 1: Did you mean to use a time based format? */
INSERT INTO #results
SELECT 1, N'Data Formats', 'USER_TABLE',  t.name, c.name, N'Column storing date should use a date or datetime format, but this column is using ' + ty.name + '.', N'https://goo.gl/uiltVb'
FROM sys.columns as c
	inner join sys.tables as t on t.object_id = c.object_id
	inner join sys.types as ty on ty.user_type_id = c.user_type_id
WHERE c.is_identity = 0 --exclude identity cols
	AND t.is_ms_shipped = 0 --exclude sys table
	AND c.name LIKE '%date%' 
	AND ty.name NOT IN ('datetime', 'datetime2', 'datetimeoffset', 'date', 'smalldatetime')
	
INSERT INTO #results 
SELECT 1, N'Data Formats', 'USER_TABLE', t.name, c.name, N'Column storing time should use a time, datetime, or sometimes integer format, but this column is using ' + ty.name + '.', N'https://goo.gl/uiltVb'
FROM sys.columns as c
	inner join sys.tables as t on t.object_id = c.object_id
	inner join sys.types as ty on ty.user_type_id = c.user_type_id
WHERE c.is_identity = 0 --exclude identity cols
	AND t.is_ms_shipped = 0 --exclude sys table
	AND c.name LIKE '%time%'
	AND ty.name NOT IN ('datetime', 'datetime2', 'datetimeoffset', 'date', 'time', 'int')
	
/* Check 2: not using reserved keywords */

/* Check 3: Object Name begins with letter */
INSERT INTO #results
SELECT 3, 'Naming Conventions', o.type_desc, o.name, NULL, N'Object names should start with a letter.', N'URL TBD'
FROM sys.objects AS [o]
WHERE type IN ('U', 'PK', 'P', 'D', 'FN', 'V')
	AND [o].[name] NOT LIKE '[a-zA-Z]%'
	
/* check 4: Only use letter, #, and _ in object names */
INSERT INTO #results
SELECT 4, 'Naming Conventions',o.type_desc, o.name, NULL, N'Object names should only contain letters, numbers, and underscores.', N'URL TBD'
FROM sys.objects AS [o]
WHERE type IN ('U', 'PK', 'P', 'D', 'FN', 'V')
AND o.name  LIKE '%[^a-zA-Z0-9_]%' 
UNION
SELECT 4, 'Naming Conventions',o.type_desc, o.name, c.name, N'Object names should only contain letters, numbers, and underscores.', N'URL TBD'
FROM sys.objects AS [o]
	INNER JOIN sys.columns as C on C.object_id = o.object_id
AND c.name  LIKE '%[^a-zA-Z0-9_]%' 

/* CHeck 5: Don't use consecutive _ in name*/
INSERT INTO #results
SELECT 5, 'Naming Conventions',o.type_desc, o.name, NULL, N'Don''t use consecutive underscores in names. ', N'URL TBD'
FROM sys.objects AS [o]
WHERE o.[type] IN ('U', 'PK', 'P', 'D', 'FN', 'V')
AND o.name LIKE '%[_][_]%' 
UNION
SELECT 5, 'Naming Conventions',o.type_desc, o.name, c.name ,N'Don''t use consecutive underscores in names.', N'URL TBD'
FROM sys.objects AS [o]
	INNER JOIN sys.columns AS C ON C.object_id = o.object_id
AND c.name LIKE '%[_][_]%' 

/* Check 6: Don't use tbl_ prefix */
INSERT INTO #results
SELECT 6, 'Naming Conventions',o.type_desc, o.name, NULL, N'Tables should not be prefixed to indicate they are tables.', N'URL TBD'
FROM sys.objects AS [o]
WHERE o.[type] IN ('U')
AND o.name LIKE 'tbl%' 

/* Check 7: Don't have col with same name as table */
INSERT INTO #results
SELECT 7, 'Naming Conventions',o.type_desc, o.name, ac.name, N'Columns should have distinct names from their table.', N'URL TBD'
FROM sys.objects as o
    inner join sys.all_columns as ac on ac.object_id = o.object_id
where o.name = ac.name

/* Check 8: Don't use FLOAT or REAL */
INSERT INTO #results
select 8, 'Data Formats', o.type_desc, o.name, ac.name, N'Are you sure you want to use ' + st.name + ' and not DECIMAL/NUMERIC?', N'https://goo.gl/uiltVb'
from sys.all_columns as ac
    inner join sys.objects as o on o.object_id = ac.object_id
    inner join sys.systypes as st on st.xtype = ac.system_type_id
where st.name IN ('float', 'real')
    and o.type_desc = 'USER_TABLE'

/* Check 9: Don't use deprecated values (NTEXT, TEXT, IMAGE) */
INSERT INTO #results
select 9, 'Data Formats', o.type_desc, o.name, ac.name, N'Deprecated data format in use: ' + st.name + '.', N'https://goo.gl/u9SgEj'
from sys.all_columns as ac
    inner join sys.objects as o on o.object_id = ac.object_id
    inner join sys.systypes as st on st.xtype = ac.system_type_id
where st.name IN ('next', 'text', 'image')
    and o.type_desc = 'USER_TABLE'

/* CHeck 10: Are heaps abound? */
/* CHeck 11: Are PK defined? */
/* Check 12: More than half cols are NULLable */
INSERT INTO #results
SELECT 12, 'Data Formats', 'USER_TABLE', o.name, NULL, N'More than half the columns (' + CAST(SUM(CAST(ac.is_nullable AS INT)) AS VARCHAR) + ' of ' + CAST(COUNT(*) AS VARCHAR) + ') accept NULL values. This might indicate misuse of NULLable columns.', N'https://goo.gl/mC7773'
FROM sys.all_columns as ac
    inner join sys.objects as o ON o.object_id = ac.object_id
WHERE o.type_desc = 'USER_TABLE'
GROUP BY o.name
HAVING SUM(CAST(ac.is_nullable AS TINYINT)) > COUNT(*) / 2.0

/* 13: Check for no FKs throughout DB*/
IF NOT EXISTS(SELECT * FROM sys.foreign_keys)
	BEGIN
		INSERT INTO #results
		SELECT 13, 'Foreign Keys', 'DB', DB_NAME(), NULL, N'No foreign keys exist in the database. It is best practice to use them.', N'https://docs.microsoft.com/en-us/sql/relational-databases/tables/primary-and-foreign-key-constraints#FKeys'
	END

/* CHeck 14: numeric or decimal without trailing 0s */
INSERT INTO #results
SELECT 14, 'Data Formats', o.type_desc, o.name, ac.name, N'Column is ' + UPPER(st.name) + '(' + CAST(ac.precision AS VARCHAR) + ',' + CAST(ac.scale AS VARCHAR) + ')' + '. Consider using an INT variety for space reduction.', N'https://goo.gl/agh5CA'
FROM sys.objects as o
    inner join sys.all_columns as ac ON ac.object_id = o.object_id
    INNER JOIN sys.systypes as st on st.xtype = ac.system_type_id
WHERE ac.scale = 0
    AND st.name IN ('decimal', 'numeric')

select * from #results;

