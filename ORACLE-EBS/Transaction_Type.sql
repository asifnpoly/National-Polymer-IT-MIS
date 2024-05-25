SELECT DISTINCT transaction_type_id, TRANSACTION_SOURCE_NAME FROM MTL_MATERIAL_TRANSACTIONS;
/


SELECT distinct
    mmt.transaction_type_id,
    mtt.transaction_type_name
FROM 
    MTL_MATERIAL_TRANSACTIONS mmt
JOIN 
    MTL_TRANSACTION_TYPES mtt
ON 
    mmt.transaction_type_id = mtt.transaction_type_id
ORDER BY 1;
