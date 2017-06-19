-- 1480 - AG Role Change (failover)
EXEC msdb.dbo.sp_add_alert
        @name = N'AG Role Change',
        @message_id = 1480,
    @severity = 0,
    @enabled = 1,
    @delay_between_responses = 0,
    @include_event_description_in = 1;
GO
EXEC msdb.dbo.sp_add_notification 
        @alert_name = N'AG Role Change', 
        @operator_name = N'John McCall', 
        @notification_method = 3; 
GO

-- 35264 - AG Data Movement - Resumed
EXEC msdb.dbo.sp_add_alert
        @name = N'AG Data Movement - Suspended',
        @message_id = 35264,
    @severity = 0,
    @enabled = 1,
    @delay_between_responses = 0,
    @include_event_description_in = 1;
GO
EXEC msdb.dbo.sp_add_notification 
        @alert_name = N'AG Data Movement - Suspended', 
        @operator_name = N'John McCall', 
        @notification_method= 3; 
GO

-- 35265 - AG Data Movement - Resumed
EXEC msdb.dbo.sp_add_alert
        @name = N'AG Data Movement - Resumed',
        @message_id = 35265,
    @severity = 0,
    @enabled = 1,
    @delay_between_responses = 0,
    @include_event_description_in = 1;
GO
EXEC msdb.dbo.sp_add_notification 
        @alert_name = N'AG Data Movement - Resumed', 
        @operator_name = N'John McCall', 
        @notification_method = 3; 
GO