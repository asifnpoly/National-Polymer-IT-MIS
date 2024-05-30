SELECT table_name, column_name
FROM all_tab_columns
WHERE upper(column_name) LIKE upper('%'||:P_COLUMN||'%');
/
