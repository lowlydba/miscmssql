SET TRANSACTION ISOLATION LEVEL 
                        READ UNCOMMITTED
SELECT 
 ROUND(s.avg_total_user_cost *
       s.avg_user_impact
        * (s.user_seeks + s.user_scans),0)
                 AS [Total Cost]
 , s.user_seeks
 ,s.user_scans
 ,s.avg_total_user_cost
 ,s.avg_user_impact
 ,d.[statement] AS [Table Name]
 ,equality_columns
 ,inequality_columns
 ,included_columns
FROM sys.dm_db_missing_index_groups g
INNER JOIN sys.dm_db_missing_index_group_stats s
  ON s.group_handle = g.index_group_handle
INNER JOIN sys.dm_db_missing_index_details d
  ON d.index_handle = g.index_handle
WHERE d.database_id = 5
ORDER BY [Total Cost] DESC