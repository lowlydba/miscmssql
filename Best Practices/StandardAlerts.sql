SET NOCOUNT ON

DECLARE @operator VARCHAR(50) = 'DBErrors';

DECLARE @errorNumbers TABLE ( ErrorNumber INT, ErrorName VARCHAR(100), NotificationMessage NVARCHAR(250))
INSERT INTO @errorNumbers VALUES 
		 (35273, '35273 - AG - Inaccessible Database', '')
		,(35274, '35274 - AG - Recovery Pending for Secondary', '')
		,(35275, '35275 - AG - Error While in Suspect State', '')
		,(35254, '35254 - AG - Error Accessing Metadata', '')
		,(35279, '35279 - AG - Attempt to Join Rejected', '')
		,(35262, '35262 - AG - Skipped startup of Database', '')
		,(35276, '35276 - AG - Failed to Schedule task', '')
		,(1480,  '1480 - AG - Role Change', '')
		,(35264, '35264 - AG - Data Movement Suspended', '')
		,(35265, '35265 - AG - Data Movement Resumed', '')
		,(9002, '9002 - Transaction log full', 'https://docs.microsoft.com/en-us/sql/relational-databases/logs/troubleshoot-a-full-transaction-log-sql-server-error-9002?view=sql-server-2017')
		,(34050, '34050 - Policy Failure (On Change Prevent)', '')
		,(34051, '34051 - Policy Failure (On Demand)', '')
		,(34052, '34052 - Policy Failure (On Schedule)', '')
		,(34053, '34053 - Policy Failure (On Change)', '');

DECLARE @severityNumbers TABLE ( SeverityNumber INT, SeverityName VARCHAR(100), NotificationMessage NVARCHAR(250))
INSERT INTO @severityNumbers VALUES
     (17, '017 - Insufficient Resources', 'The statement has caused system resources (memory, disk space, etc.) to run out. An error that cannot be corrected by the user.')
    ,(18, '018 - Nonfatal Internal Error', 'A problem with SQL Server, but the statement has completed execution and the user is not disconnected.')
    ,(19, '019 - Fatal Error in Resource', 'A limitation of SQL Server has been triggered and the query and/or batch has been terminated.')
    ,(20, '020 - Fatal Error in Current Process', 'A statement has encountered a problem, but it is unlikely to have caused harm to the database. The statement has probably been terminated.')
    ,(21, '021 - Fatal Error in Database Processes', 'A problem has occurred that will affect all statements in the database, but the database is not likely to be permanently damaged.')
    ,(22, '022 - Fatal Error: Table Integrity Suspect', 'A table or index has been damaged by either a hardware or software problem. A DBCC CHECKDB should be run on the object to diagnose further.')
    ,(23, '023 - Fatal Error: Database Integrity Suspect', 'The database may have been damaged by either a hardware or software problem. A DBCC CHECKDB should be run on the entire database to diagnose further.')
    ,(24, '024 - Fatal Error: Hardware Error', 'Hardware failure. Usually results in restoring the database from a backup and having the hardware, especially storage, checked for issues.')
    ,(25, '025 - Fatal Error', '')


PRINT 'USE [msdb]'
PRINT 'GO'
PRINT '/* *************************************************************** */ '

/* Error Number based alerts */
DECLARE  @thisErrorNumber VARCHAR(6);
DECLARE	 @thisErrorName VARCHAR(100);
DECLARE  @notificationMessage NVARCHAR(250);

DECLARE  cur_ForEachErrorNumber CURSOR LOCAL FAST_FORWARD
FOR SELECT ErrorNumber, ErrorName, NotificationMessage FROM @errorNumbers

OPEN  cur_ForEachErrorNumber

FETCH NEXT FROM cur_ForEachErrorNumber INTO @thisErrorNumber, @thisErrorName, @notificationMessage
WHILE @@FETCH_STATUS = 0
BEGIN
 PRINT 
  'EXEC msdb.dbo.sp_add_alert @name=N'''+ @thisErrorName + ''',
  @message_id=' + @thisErrorNumber + ', 
  @severity=0, 
  @enabled=1, 
  @notification_message=N''' + @notificationMessage + ''',
  @delay_between_responses=0, 
  @include_event_description_in=1;
  GO
  EXEC msdb.dbo.sp_add_notification @alert_name=N'''+ @thisErrorName + ''', 
    @operator_name=N''' + @operator + ''', @notification_method = 1
  GO '
 PRINT '/* *************************************************************** */ '
 FETCH NEXT FROM cur_ForEachErrorNumber INTO @thisErrorNumber, @thisErrorName, @notificationMessage
END

CLOSE  cur_ForEachErrorNumber
DEALLOCATE cur_ForEachErrorNumber;

/* Severity based alerts */
DECLARE  @thisSeverityNumber VARCHAR(6);
DECLARE	 @thisSeverityName VARCHAR(100);

DECLARE  cur_ForEachSeverityNumber CURSOR LOCAL FAST_FORWARD
FOR SELECT SeverityNumber, SeverityName, NotificationMessage FROM @severityNumbers;

OPEN  cur_ForEachSeverityNumber

FETCH NEXT FROM cur_ForEachSeverityNumber INTO @thisSeverityNumber, @thisSeverityName, @notificationMessage
WHILE @@FETCH_STATUS = 0
BEGIN
 PRINT 
  'EXEC msdb.dbo.sp_add_alert @name=N'''+ @thisSeverityName + ''',
  @message_id=0, 
  @severity=' + @thisSeverityNumber + ', 
  @enabled=1,
  @notification_message=N''' + @notificationMessage + ''',
  @delay_between_responses=0, 
  @include_event_description_in=1;
  GO
  EXEC msdb.dbo.sp_add_notification @alert_name=N'''+ @thisSeverityName + ''', 
    @operator_name=N''' + @operator + ''', @notification_method = 1
  GO '
 PRINT '/* *************************************************************** */ '
 FETCH NEXT FROM cur_ForEachSeverityNumber INTO @thisSeverityNumber, @thisSeverityName, @notificationMessage
END

CLOSE  cur_ForEachSeverityNumber
DEALLOCATE cur_ForEachSeverityNumber;
