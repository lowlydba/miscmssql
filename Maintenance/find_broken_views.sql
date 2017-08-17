 begin try
     select
       schema_name( V.schema_id ) as schemaName,
        V.name,
        V.type_desc
    from
         sys.all_objects as V
            cross apply sys.dm_sql_referenced_entities( concat( schema_name(V.schema_id), N'.', V.name ), N'OBJECT' ) as RE
    where
         RE.referenced_id is null
     group by
        V.name,
         V.schema_id,
         V.type_desc
     order by schemaName, name;
 end try
 begin catch
 end catch;