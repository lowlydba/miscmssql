select DISTINCT CAST(SCHEMA_NAME(ao.schema_id) AS NVARCHAR(30)) 'Schema', CAST(OBJECT_NAME(ao.object_id) AS NVARCHAR(50)) AS 'Object', CAST((ac.name) AS NVARCHAR(10)) AS 'Column referenced', sd.is_select_all, sd.is_selected, sd.is_updated
from sys.sql_dependencies sd
INNER JOIN sys.all_objects ao ON ao.object_id = sd.object_id
LEFT JOIN sys.all_columns ac ON ac.column_id = sd.referenced_minor_id
WHERE OBJECT_NAME(sd.referenced_major_id) = 'CohortRoundActual'
 AND (ac.name) = 'Active'