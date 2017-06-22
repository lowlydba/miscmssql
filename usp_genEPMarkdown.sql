SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_genEPMarkdown]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[usp_genEPMarkdown] AS' 
END
GO



ALTER   PROCEDURE [dbo].[usp_genEPMarkdown]
					   @dbname SYSNAME = NULL
AS
SET NOCOUNT ON;

--Check if database name was passed.
IF (@dbname IS NULL) 
    BEGIN;
	   THROW 51000, 'No database provided.', 1;
    END
ELSE
    SET @dbname = QUOTENAME(@dbname); --Avoid injections

--Build query to generate Git-compatible markdown table.
--Assumes you're using MS_DESCRIPTION for your Extended Properties. 
DECLARE @sql NVARCHAR(MAX);
SET @sql = N'
USE ' + @dbname + '

DECLARE @markdown NVARCHAR(MAX);

SELECT @markdown = N''| Schema | Obj Type | Obj Name | Col Name | Comment |'' + CHAR(13) +
		         N''| ------ | -------- | -------- | -------- | ------- |'' + CHAR(13) ;

SELECT @markdown = @markdown + CONCAT(SCHEMA_NAME([o].[schema_id]), '' | '', [o].[type_desc], '' | '', OBJECT_NAME([ep].major_id), '' | '', ISNULL([syscols].[name], ''N/A'') , '' | '', CAST([ep].[value] AS VARCHAR(200)), CHAR(13))
FROM [sys].[extended_properties] AS [ep]
    INNER JOIN [sys].[all_objects] AS [o] ON [o].[object_id] = [ep].[major_id]
    LEFT JOIN [sys].[columns] AS [SysCols] ON [ep].[major_id] = [SysCols].[object_id]
                                AND [ep].[minor_id] = [SysCols].[column_id]
WHERE   [ep].[name] = ''MS_Description''
ORDER BY SCHEMA_NAME([o].[schema_id]), [o].[type_desc], OBJECT_NAME([ep].major_id);

select @markdown;'

--Run query
EXEC sp_executesql @sql;

GO


