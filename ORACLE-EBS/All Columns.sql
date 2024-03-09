SELECT column_name
FROM all_tab_columns
WHERE UPPER(table_name) = UPPER(:P_TABLE_NAME)
  AND UPPER(owner) = UPPER(:P_SCHEMA_NAME);
