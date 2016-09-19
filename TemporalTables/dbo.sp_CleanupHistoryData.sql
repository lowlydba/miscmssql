/* 
----------------------
Info
----------------------

This version differs from the MSDN version (https://msdn.microsoft.com/en-us/library/mt637341.aspx) in two ways:
 1. It works if your history table is in a different schema
 2. Provides variable values in the error catching clause for easier debugging

----------------------
Usage
----------------------

DECLARE @temporalTableSchema sysname = 'TableName'
DECLARE @temporalTableName sysname = 'SchemaName'
DECLARE @cleanupOlderThanDate datetime2(7) = GETDATE() - 7;

EXECUTE [dbo].[sp_CleanupHistoryData] 
   @temporalTableSchema 
  ,@temporalTableName 
  ,@cleanupOlderThanDate
GO

 */
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_CleanupHistoryData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[sp_CleanupHistoryData] AS' 
END
GO

ALTER PROCEDURE [dbo].[sp_CleanupHistoryData]  
         @temporalTableSchema sysname  
       , @temporalTableName sysname  
       , @cleanupOlderThanDate datetime2  
AS  
    DECLARE @disableVersioningScript nvarchar(max) = '';  
    DECLARE @deleteHistoryDataScript nvarchar(max) = '';  
    DECLARE @enableVersioningScript nvarchar(max) = '';  
  
DECLARE @historyTableName sysname    
DECLARE @historyTableSchema sysname    
DECLARE @periodColumnName sysname    
  
/*Generate script to discover history table name and end of period column for given temporal table name*/  
EXECUTE sp_executesql   
    N'SELECT @hst_tbl_nm = t2.name, @hst_sch_nm = SCHEMA_NAME(t2.schema_id), @period_col_nm = c.name  
        FROM sys.tables t1   
           JOIN sys.tables t2 on t1.history_table_id = t2.object_id  
        JOIN sys.schemas s on t1.schema_id = s.schema_id  
            JOIN sys.periods p on p.object_id = t1.object_id  
           JOIN sys.columns c on p.end_column_id = c.column_id and c.object_id = t1.object_id  
                  WHERE   
                 t1.name = @tblName and s.name = @schName'  
                , N'@tblName sysname  
                , @schName sysname  
                , @hst_tbl_nm sysname OUTPUT  
                , @hst_sch_nm sysname OUTPUT  
                , @period_col_nm sysname OUTPUT'  
                , @tblName = @temporalTableName  
                , @schName = @temporalTableSchema  
                , @hst_tbl_nm = @historyTableName OUTPUT  
                , @hst_sch_nm = @historyTableSchema OUTPUT  
                , @period_col_nm = @periodColumnName OUTPUT   
  

/*Verify if history table exists */
IF @historyTableName IS NULL OR @historyTableSchema IS NULL OR @periodColumnName IS NULL  
    BEGIN
	   SELECT @historyTableName AS [history_table_name], @historyTableSchema AS [history_table_schema], @periodColumnName AS [period_col_nanme];
	   THROW 50010, 'History table cannot be found. Either specified table is not system-versioned temporal or you have provided incorrect argument values.', 1  
    END
  
/*Generate 3 statements that will run inside a transaction: SET SYSTEM_VERSIONING = OFF, DELETE FROM history_table, SET SYSTEM_VERSIONING = ON */  
SET @disableVersioningScript =  @disableVersioningScript + 'ALTER TABLE [' + @temporalTableSchema + '].[' + @temporalTableName + '] SET (SYSTEM_VERSIONING = OFF)'  
SET @deleteHistoryDataScript =  @deleteHistoryDataScript + ' DELETE FROM  [' + @historyTableSchema + '].[' + @historyTableName + ']   
     WHERE ['+ @periodColumnName + '] < ' + '''' + convert(varchar(128), @cleanupOlderThanDate, 126) +  ''''   
SET @enableVersioningScript =  @enableVersioningScript + ' ALTER TABLE [' + @temporalTableSchema + '].[' + @temporalTableName + ']   
    SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [' + @historyTableSchema + '].[' + @historyTableName + '], DATA_CONSISTENCY_CHECK = OFF )); '   
  
BEGIN TRAN  
    EXEC (@disableVersioningScript);  
    EXEC (@deleteHistoryDataScript);  
    EXEC (@enableVersioningScript);  
COMMIT;  
GO


