BEGIN
 SET NOCOUNT ON;
  
  --Declare any vars at the top
  DECLARE @Var1 NVARCHAR(10) = NULL;
 
  --If DML is included, use a transaction
  BEGIN TRY
      BEGIN TRAN
          --DML Statements
      COMMIT;
  END TRY
  
--Catch any errors, include stored proc name for stack trace & cheeky link to SE
BEGIN CATCH;
       IF (XACT_STATE()) = -1 OR ((XACT_STATE()) = 1 AND (@@TRANCOUNT = 0 OR @@TRANCOUNT > 0))
          BEGIN
             ROLLBACK TRAN;
             DECLARE @errMsg NVARCHAR(MAX)= FORMATMESSAGE('%s: %s Try troubleshooting: http://dba.stackexchange.com/search?q=msg+%i', OBJECT_NAME(@@PROCID),ERROR_MESSAGE(),ERROR_NUMBER());
             THROW 51000, @errMsg, 1; --Throw error
          END
END CATCH