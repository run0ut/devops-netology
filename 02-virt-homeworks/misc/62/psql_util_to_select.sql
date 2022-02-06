/*  ~psql \l, https://www.postgresqltutorial.com/postgresql-show-tables/ */
SELECT schemaname, tablename, tableowner
FROM pg_catalog.pg_tables
WHERE schemaname != 'pg_catalog' AND
    schemaname != 'information_schema';
/* ~psql \dt <table> поля и их свойства, https://www.postgresqltutorial.com/postgresql-describe-table/ */
SELECT
   TABLE_NAME, column_name, data_type, character_maximum_length, column_default, is_nullable
   -- *
FROM
   information_schema.columns
WHERE
   table_name IN ('orders', 'clients')
ORDER BY
	1,3;
/* ~psql \td <table> внешние ключи, https://stackoverflow.com/questions/1152260/how-to-list-table-foreign-keys */
SELECT
    tc.table_schema,
    tc.constraint_name,
    tc.table_name,
    kcu.column_name,
    ccu.table_schema AS foreign_table_schema,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM
    information_schema.table_constraints AS tc
    JOIN information_schema.key_column_usage AS kcu
      ON tc.constraint_name = kcu.constraint_name
      AND tc.table_schema = kcu.table_schema
    JOIN information_schema.constraint_column_usage AS ccu
      ON ccu.constraint_name = tc.constraint_name
      AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY';
