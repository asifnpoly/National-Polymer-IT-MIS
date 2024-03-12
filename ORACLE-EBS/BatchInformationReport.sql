SELECT gbh.BATCH_NO,
       gmds.BATCH_ID,
       DECODE (gbh.BATCH_STATUS,
                 1, 'Pending',
                 2, 'WIP',
                 3, 'Completed',
                 4, 'Closed',
                 'Cancelled')    batch_STATUS_NAME,
       gbh.ACTUAL_START_DATE,
       gbh.ACTUAL_CMPLT_DATE,
       gbh.BATCH_CLOSE_DATE,
       msik.CONCATENATED_SEGMENTS AS "Item Code",
       msik.DESCRIPTION AS "Items",
       gmds.ACTUAL_QTY,
       gmds.organization_id,
       gmds.inventory_item_id,
       round(gmd.cost_alloc,2) as "Cost Allocation", 
       gmd.FORMULALINE_ID
FROM gme_batch_header gbh,
     gme_material_details gmds,
     gme_material_details gmd,
     HR_OPERATING_UNITS hou,
     MTL_SYSTEM_ITEMS_KFV msik
WHERE gmds.inventory_item_id = gmd.inventory_item_id
  AND gmds.inventory_item_id = msik.inventory_item_id
  AND gmd.ORGANIZATION_ID = msik.ORGANIZATION_ID
  AND gmds.organization_id = gmd.organization_id
  AND gmds.BATCH_ID = gmd.BATCH_ID
  AND gmd.BATCH_ID = gbh.BATCH_ID
  AND gmds.line_type = -1
  AND gmd.line_type = 1
  AND 1 = 1 
  AND hou.ORGANIZATION_ID = :org_id
ORDER BY gmds.line_no;