--------------------------210
SELECT PRD_ITEM
FROM XX_FORMULA_UPLOAD
MINUS
SELECT CONCATENATED_SEGMENTS 
FROM mtl_system_items_kfv
where organization_id = 81;


SELECT ING_ITEM_CODE
FROM XX_FORMULA_UPLOAD
MINUS
SELECT CONCATENATED_SEGMENTS 
FROM mtl_system_items_kfv
where organization_id = 81;
-------------------------------------110

SELECT ING_ITEM_CODE
FROM XX_FORMULA_UPLOAD110
MINUS
SELECT CONCATENATED_SEGMENTS 
FROM mtl_system_items_kfv
where organization_id = 81;


SELECT PRD_ITEM
FROM XX_FORMULA_UPLOAD110
MINUS
SELECT CONCATENATED_SEGMENTS 
FROM mtl_system_items_kfv
where organization_id = 81;