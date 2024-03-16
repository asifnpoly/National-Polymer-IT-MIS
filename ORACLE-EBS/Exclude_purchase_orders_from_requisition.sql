SELECT 
    ROW_NUMBER() Over (Order by 1) as "SL",
    PRH.SEGMENT1       as "PR Number",
    PRH.CREATION_DATE  as "PR Create Date",
    PRH.APPROVED_DATE   as "PR Approved Date",
    PRH.AUTHORIZATION_STATUS as "Status",
    MTL.CONCATENATED_SEGMENTS       as "Items Code", -- Assuming you want the ITEM_ID here, change to PRL.ITEM_NAME if needed
    PRL.ITEM_ID  as "Item ID",
    PRL.ITEM_DESCRIPTION as "Item Description", 
    PRL.UNIT_MEAS_LOOKUP_CODE as "Unit",
    PRL.QUANTITY,
    XX_COM_PKG.GET_USER_NAME(PRH.CREATED_BY) as "User Name",
    PRH.ATTRIBUTE1     as "Department",
    PRH.ORG_ID,
    (SELECT NAME FROM HR_OPERATING_UNITS HOU WHERE HOU.ORGANIZATION_ID=PRH.ORG_ID) UNIT_NAME,
    TO_CHAR(CURRENT_TIMESTAMP,'DD-MON-YY HH12:MI:SS AM') PRINTED_DATE,
    XX_COM_PKG.GET_USER_NAME(:P_PRINTED_BY_ID) PRINTED_BY,
    :P_REPORT_NAME REPORT_NAME,
    :P_FROM_DATES FROM_DATE,
    :P_TO_DATES   TO_DATE
FROM 
    PO.PO_REQUISITION_HEADERS_ALL PRH
    JOIN PO.PO_REQUISITION_LINES_ALL PRL ON PRH.REQUISITION_HEADER_ID = PRL.REQUISITION_HEADER_ID
    JOIN MTL_SYSTEM_ITEMS_KFV MTL ON PRL.ITEM_ID = MTL.INVENTORY_ITEM_ID
WHERE 
    trunc(PRH.CREATION_DATE) BETWEEN '01-JAN-24' AND '29-FEB-24'
    AND PRH.ORG_ID = :P_ORGANIZATION_ID -- Your organization ID
    AND NOT EXISTS (
        SELECT 1
        FROM PO_HEADERS_ALL POH
        JOIN PO_LINES_ALL POL ON POH.PO_HEADER_ID = POL.PO_HEADER_ID
        WHERE POL.ITEM_ID = PRL.ITEM_ID
    );
