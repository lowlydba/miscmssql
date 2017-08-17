SET NOCOUNT ON

-- first create a temporary table to store your target error numbers
DECLARE @errorNumbers TABLE ( ErrorNumber VARCHAR(6) )
INSERT INTO @errorNumbers
 VALUES ('35273'),('35274'),('35275'),('35254'),('35279'),('35262'),('35276')

-- get the correct DB context
PRINT 'USE [msdb]'
PRINT 'GO'
PRINT '/* *************************************************************** */ '

-- use a cursor to iterate over each error number (yes, I know)...
DECLARE  @thisErrorNumber VARCHAR(6)

DECLARE  cur_ForEachErrorNumber CURSOR LOCAL FAST_FORWARD
FOR SELECT ErrorNumber FROM @errorNumbers

OPEN  cur_ForEachErrorNumber

FETCH NEXT FROM cur_ForEachErrorNumber INTO @thisErrorNumber
WHILE @@FETCH_STATUS = 0
BEGIN
 PRINT 
  'EXEC msdb.dbo.sp_add_alert @name=N''HA Error - ' + @thisErrorNumber + ''',
  @message_id=' + @thisErrorNumber + ', 
  @severity=0, 
  @enabled=1, 
  @delay_between_responses=0, 
  @include_event_description_in=1, 
  @job_id=N''00000000-0000-0000-0000-000000000000''
  GO
  EXEC msdb.dbo.sp_add_notification @alert_name=N''HA Error - ' + @thisErrorNumber + ''', 
    @operator_name=N''Infra Alerts'', @notification_method = 1
  GO '
 PRINT '/* *************************************************************** */ '
 FETCH NEXT FROM cur_ForEachErrorNumber INTO @thisErrorNumber
END

CLOSE  cur_ForEachErrorNumber
DEALLOCATE cur_ForEachErrorNumber