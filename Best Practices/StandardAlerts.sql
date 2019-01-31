
BEGIN TRANSACTION
  
/*************************************************
https://docs.microsoft.com/en-us/sql/relational-databases/errors-events/database-engine-error-severities?view=sql-server-2017
Alter these variables to your preferences:
*************************************************/
DECLARE
    @DELAY_BETWEEN_RESPONSES INT = 1800
    ,@OPERATOR_NAME NVARCHAR(1000) = 'Infra Alerts'
  
DECLARE
    @NO_TOTAL_ALERTS INT
    ,@ROWPOSITION INT = 1
    ,@ALERT_NAME VARCHAR(1000)
    ,@SEVERITYNO INT
    ,@ERRORNO INT
  
DECLARE @TBL_ALERTS TABLE
    (
        ROWCOUNTER INT IDENTITY(1,1) NOT NULL
        ,SEVERITYNO INT NULL
        ,ERRORNO INT NULL
        ,ALERT_NAME VARCHAR(100) NOT NULL
    )
  
/*************************************************
Enter general alerts here:
*************************************************/
INSERT @TBL_ALERTS (SEVERITYNO, ALERT_NAME) VALUES
    (17, '017 - Insufficient Resources')
    ,(18, '018 - Nonfatal Internal Error')
    ,(19, '019 - Fatal Error in Resource')
    ,(20, '020 - Fatal Error in Current Process')
    ,(21, '021 - Fatal Error in Database Processes')
    ,(22, '022 - Fatal Error: Table Integrity Suspect')
    ,(23, '023 - Fatal Error: Database Integrity Suspect')
    ,(24, '024 - Fatal Error: Hardware Error')
    ,(25, '025 - Fatal Error')
  
/*************************************************
Enter alters on specific errors here:
(9002 is included for demonstration purposes only)
*************************************************/
INSERT @TBL_ALERTS (ERRORNO, ALERT_NAME) VALUES
    (9002, '9002 - Transaction log full'),
    (34050, '34050 - Policy Failure (On Change Prevent)'),
    (34051, '34051 - Policy Failure (On Demand)'),
    (34052, '34052 - Policy Failure (On Schedule)'),
    (34053, '34053 - Policy Failure (On Change)');
  
SELECT @NO_TOTAL_ALERTS = COUNT(*) FROM @TBL_ALERTS
  
BEGIN TRY
  
    WHILE @ROWPOSITION <= @NO_TOTAL_ALERTS BEGIN
  
        SELECT
            @ALERT_NAME = ALERT_NAME + ' - ' + @@SERVERNAME
            ,@SEVERITYNO = SEVERITYNO
            ,@ERRORNO = ERRORNO
        FROM
            @TBL_ALERTS
        WHERE
            ROWCOUNTER = @ROWPOSITION
  
        --DROP IF ALREADY EXISTSING
        IF EXISTS (SELECT * FROM msdb.dbo.sysalerts WHERE [name] = @ALERT_NAME) BEGIN
            EXEC msdb.dbo.sp_delete_alert @name=@ALERT_NAME
        END
  
        IF @SEVERITYNO IS NOT NULL BEGIN
            EXEC msdb.dbo.sp_add_alert @name = @ALERT_NAME,
                    @message_id=0, 
                    @severity=@SEVERITYNO, 
                    @enabled=1, 
                    @delay_between_responses=@DELAY_BETWEEN_RESPONSES, 
                    @include_event_description_in=1, 
                    @job_id=N'00000000-0000-0000-0000-000000000000'
        END
  
        IF @ERRORNO IS NOT NULL BEGIN
            EXEC msdb.dbo.sp_add_alert @name = @ALERT_NAME,
                    @message_id=@ERRORNO, 
                    @severity=0, 
                    @enabled=1, 
                    @delay_between_responses=@DELAY_BETWEEN_RESPONSES, 
                    @include_event_description_in=1, 
                    @job_id=N'00000000-0000-0000-0000-000000000000'
        END
  
        EXEC msdb.dbo.sp_add_notification @alert_name=@ALERT_NAME, @operator_name=@OPERATOR_NAME, @notification_method = 1
  
        SELECT @ROWPOSITION = @ROWPOSITION + 1
    END
END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE()
  
    IF @@TRANCOUNT > 0 BEGIN
        ROLLBACK
    END
END CATCH
  
IF @@TRANCOUNT > 0 BEGIN
    COMMIT
END
