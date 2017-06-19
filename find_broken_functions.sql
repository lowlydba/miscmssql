--WOrk in progress


select 'SELECT COUNT(*) FROM sys.dm_sql_referenced_entities (''' + s.name + '.' + o.name + ''', ''OBJECT'')'   from sys.objects o
inner join sys.schemas s ON o.schema_id = s.schema_id
where type = 'FN'
