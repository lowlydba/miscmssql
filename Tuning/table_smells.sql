WITH TableSmells (TableName, Problem, Object_ID )AS
(
SELECT object_schema_name(Object_ID)+'.'+object_name(Object_ID), problem,Object_ID FROM
  (
  SELECT object_id, 'wide (more than 15 columns)'
    FROM sys.tables /* see whether the table has more than 15 columns */
    WHERE  max_column_id_used>15
  UNION ALL
    SELECT DISTINCT sys.tables.object_id, 'heap'
      FROM sys.indexes/* see whether the table is a heap */
      INNER JOIN sys.tables ON sys.tables.object_ID=sys.indexes.object_ID
      WHERE sys.indexes.type=0
  UNION ALL
    SELECT sys.tables.object_id, 'No primary key'
      FROM sys.tables/* see whether the table has a primary key */
      WHERE objectproperty(OBJECT_ID,'TableHasPrimaryKey') = 0
  UNION ALL
    SELECT sys.tables.object_id, 'No index at all'
      FROM sys.tables /* see whether the table has any index */
      WHERE objectproperty(OBJECT_ID,'TableHasIndex') = 0
  UNION ALL
       SELECT sys.tables.object_id, 'No candidate key'
      FROM sys.tables/* if no unique constraint then it isn't relational */
      WHERE objectproperty(OBJECT_ID,'TableHasUniqueCnst') = 0
      AND   objectproperty(OBJECT_ID,'TableHasPrimaryKey') = 0
  UNION ALL
    SELECT DISTINCT object_id, 'disabled Index(es)'
      FROM sys.indexes /* don't leave these lying around */
      WHERE is_disabled=1
  UNION ALL
    SELECT DISTINCT parent_object_id, 'disabled constraint(s)'
      FROM sys.check_constraints /* hmm. i wonder why */
      WHERE is_disabled=1
  UNION ALL
    SELECT DISTINCT parent_object_id, 'untrusted constraint(s)'
      FROM sys.check_constraints /* ETL gone bad? */
      WHERE is_not_trusted=1
  UNION ALL
    SELECT DISTINCT parent_object_id, 'disabled FK'
      FROM sys.foreign_keys /* build script gone bad? */
      WHERE is_disabled=1
  UNION ALL
    SELECT DISTINCT Parent_object_id, 'untrusted FK'
      FROM sys.foreign_keys /* Why do you have untrusted FKs?       
      Constraint was enabled without checking existing rows;
      therefore, the constraint may not hold for all rows. */
      WHERE is_not_trusted=1
  UNION ALL
/*
    SELECT  sys.tables.object_id, 'unrelated to any other table'
      FROM sys.tables
      LEFT OUTER join
        (SELECT referenced_object_id AS table_ID
           FROM sys.foreign_keys
         UNION ALL
           SELECT parent_object_id
             FROM sys.foreign_keys
        )referenced(table_ID)
      ON referenced.table_ID=sys.Tables.object_ID
      WHERE referenced.table_id IS null*/
    SELECT  sys.tables.object_id, 'unrelated to any other table'
      FROM sys.tables /* found a simpler way! */
      WHERE objectpropertyex(OBJECT_ID,'TableHasForeignKey')=0
      AND objectpropertyex(OBJECT_ID,'TableHasForeignRef')=0
  UNION ALL
    SELECT DISTINCT object_id, 'unintelligible column names'
      FROM sys.columns /* column names with no letters in them */
      WHERE name COLLATE  Latin1_general_CI_AI
            NOT LIKE '%[A-Z]%' COLLATE Latin1_general_CI_AI
  UNION ALL
    SELECT DISTINCT object_id, 'non-compliant column names'
      FROM sys.columns /* column names that need delimiters*/
      WHERE name COLLATE  Latin1_general_CI_AI
          LIKE '%[^_@$#A-Z0-9]%' COLLATE  Latin1_general_CI_AI
  UNION ALL
    SELECT DISTINCT parent_ID, 'has a disabled trigger' 
      FROM sys.triggers
      WHERE is_disabled=1 AND parent_ID>0
  UNION ALL
    SELECT sys.tables.object_id, 'can''t be indexed'
      FROM sys.tables/* see whether the table has a primary key */
      WHERE objectproperty(OBJECT_ID,'IsIndexable') = 0
  )f(Object_ID,Problem)
)
SELECT TableName,
       CASE WHEN count(*)>1 THEN /*only do correlated subquery when necessary*/
       stuff(( SELECT ', '+problem
           FROM TableSmells t2
          WHERE t1.tableName = t2.TableName
          ORDER BY problem
           FOR XML PATH(''), TYPE).value(N'(./text())[1]',N'varchar(8000)'),1,2,'')
       ELSE max(problem) END
  FROM TableSmells t1 WHERE OBJECTPROPERTYEX(t1.object_ID, 'IsTable')=1
  GROUP BY TableName;