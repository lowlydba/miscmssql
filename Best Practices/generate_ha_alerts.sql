SET NOCOUNT ON

--Store error codes/name
DECLARE @errorNumbers TABLE ( ErrorNumber VARCHAR(6), ErrorName VARCHAR(100) )
INSERT INTO @errorNumbers
 VALUES ('35273', '35273 - AG - Inaccessible Database')
		,('35274', '35274 - AG - Recovery Pending for Secondary')
		,('35275', '35275 - AG - Error While in Suspect State')
		,('35254', '35254 - AG - Error Accessing Metadata')
		,('35279', '35279 - AG - Attempt to Join Rejected')
		,('35262', '35262 - AG - Skipped startup of Database')
		,('35276', '35276 - AG - Failed to Schedule task')

--Choose operator to notify
DECLARE @operator VARCHAR(50) = '';

-- get the correct DB context
PRINT 'USE [msdb]'
PRINT 'GO'
PRINT '/* *************************************************************** */ '

-- use a cursor to iterate over each error number (yes, I know)...
DECLARE  @thisErrorNumber VARCHAR(6)
DECLARE	 @thisErrorName VARCHAR(100)

DECLARE  cur_ForEachErrorNumber CURSOR LOCAL FAST_FORWARD
FOR SELECT ErrorNumber, ErrorName FROM @errorNumbers

OPEN  cur_ForEachErrorNumber

FETCH NEXT FROM cur_ForEachErrorNumber INTO @thisErrorNumber, @thisErrorName
WHILE @@FETCH_STATUS = 0
BEGIN
 PRINT 
  'EXEC msdb.dbo.sp_add_alert @name=N'''+ @thisErrorName + ''',
  @message_id=' + @thisErrorNumber + ', 
  @severity=0, 
  @enabled=1, 
  @delay_between_responses=0, 
  @include_event_description_in=1, 
  GO
  EXEC msdb.dbo.sp_add_notification @alert_name=N'''+ @thisErrorName + ''', 
    @operator_name=N''' + @operator + ''', @notification_method = 1
  GO '
 PRINT '/* *************************************************************** */ '
 FETCH NEXT FROM cur_ForEachErrorNumber INTO @thisErrorNumber, @thisErrorName 
END

CLOSE  cur_ForEachErrorNumber
DEALLOCATE cur_ForEachErrorNumber
