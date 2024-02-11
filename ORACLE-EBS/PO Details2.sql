SELECT DISTINCT pha.org_id,
                  hou.NAME,
                  PHA.PO_HEADER_ID,
                  PHA.SEGMENT1                   AS "PO NUMBER",
                  pha.AUTHORIZATION_STATUS,
                  pha.creation_date,
                  pha.APPROVED_DATE,
                  pha.CLOSED_DATE,
                  PHA.CLOSED_CODE,
                  APS.VENDOR_NAME                AS "SUPPLIER",
                  MSIK.concatenated_segments     AS "ITEM CODE",
                  MSIK.DESCRIPTION,
                  PLA.QUANTITY                   AS "QUANTITY",
                  pha.currency_code,
                  PLA.UNIT_PRICE
    FROM PO_HEADERS_ALL      PHA,
         PO_LINES_ALL        PLA,
         MTL_SYSTEM_ITEMS_KFV MSIK,
         HR_OPERATING_UNITS  HOU,
         AP_SUPPLIERS        APS
   WHERE     PHA.PO_HEADER_ID = PLA.PO_HEADER_ID
         AND pha.org_id = HOU.ORGANIZATION_ID
         AND pha.org_id = pLa.org_id
         AND pLa.org_id = HOU.ORGANIZATION_ID
         AND PLA.ITEM_ID = MSIK.INVENTORY_ITEM_ID
         AND HOU.ORGANIZATION_ID = MSIK.ORGANIZATION_ID
         AND PHA.VENDOR_ID = APS.VENDOR_ID
         AND pha.creation_date > '31-MAY-23'
         AND PHA.ATTRIBUTE1 LIKE 'I%'
ORDER BY PHA.ORG_ID, PHA.SEGMENT1, pha.creation_date
--    AND ROWNUM < 100; -- Limit by 100 rows