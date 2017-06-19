exec sp_resetstatus [tto_ods_dev_6_5_15]
alter database [tto_ods_dev_6_5_15]set emergency
dbcc checkdb([tto_ods_dev_6_5_15])

ALTER DATABASE [tto_ods_dev_6_5_15] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
DBCC CheckDB ([tto_ods_dev_6_5_15], REPAIR_ALLOW_DATA_LOSS)
ALTER DATABASE [tto_ods_dev_6_5_15] SET MULTI_USER