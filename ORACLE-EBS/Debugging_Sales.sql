SELECT OE.LINE_NUMBER || '.' || OE.SHIPMENT_NUMBER Line_num,
         CASE
            WHEN OH.ORG_ID = 101 THEN 'Form NO: 08-05-DST-00-02'
            WHEN OH.ORG_ID = 102 THEN 'Form NO: 08-05-DST-00-02'
         END
            CF_FROM,
         CASE
            WHEN OH.ORG_ID = 101 THEN 'Rev: 01'
            WHEN OH.ORG_ID = 102 THEN 'Rev: 00'
         END
            CF_REV,
         XX_CHALLAN_COMP_NAME (OOD.ORGANIZATION_CODE, OH.HEADER_ID) OU_CODE,
         OOD.ORGANIZATION_CODE WH_CODE,
         OE.SHIP_FROM_ORG_ID,
         OE.SHIP_FROM_ORG_ID,
         NVL (XX_REC_ADRESSCUS (oh.header_id),
              OH.Attribute7 || ' ' || OH.Attribute8)
            Receiver_Name,
         SPN.RESOURCE_NAME SPN_NAME,
         SPN.SOURCE_PHONE PHN,
         OH.SOLD_TO || ', (' || OH.CUSTOMER_NUMBER || ')' CUSTOMER_NAME,
            OH.INVOICE_TO_ADDRESS1
         || ', '
         || OH.INVOICE_TO_ADDRESS2
         || ', '
         || OH.INVOICE_TO_ADDRESS3
         || ', '
         || OH.INVOICE_TO_ADDRESS4
         || ', '
         || OH.INVOICE_TO_ADDRESS5
            BILL_TO,
         NVL (
            XX_DEL_ADRESSCUSTWO (OH.Header_ID),
            NVL (
               XX_DEL_ADRESSCUS (OH.Header_ID),
               NVL (
                  OH.ATTRIBUTE11,
                  (DECODE (
                      WH.ADDITIONAL_SHIPMENT_INFO,
                      NULL, DECODE (
                               OH.SHIPPING_INSTRUCTIONS,
                               NULL,    OH.SHIP_TO_ADDRESS1
                                     || ', '
                                     || OH.SHIP_TO_ADDRESS2
                                     || ', '
                                     || OH.SHIP_TO_ADDRESS3
                                     || ', '
                                     || OH.SHIP_TO_ADDRESS4
                                     || ', '
                                     || OH.SHIP_TO_ADDRESS5,
                               OH.SHIPPING_INSTRUCTIONS),
                      WH.ADDITIONAL_SHIPMENT_INFO)))))
            SHIP_TO,
         WH.NAME CHALLAN_NO,
         TO_CHAR (WH.INITIAL_PICKUP_DATE, 'DD/MM/YYYY HH:MI:SS PM')
            AS CHALLAN_DATE,
         oh.ORDER_NUMBER DO_NO,
         OH.ORDERED_DATE DO_Date,
         tp.ATTRIBUTE1 TRANSPORTER,
         mtl.CONCATENATED_SEGMENTS Item_Code,
         MTL.DESCRIPTION,                               --WL.ITEM_DESCRIPTION,
         SUM (WL.REQUESTED_QUANTITY) REQ_QTY,
         WL.REQUESTED_QUANTITY_UOM,
         SUM (NVL (WL.DELIVERED_QUANTITY, WL.SHIPPED_QUANTITY)) DEL_QTY,
         OH.SOLD_TO_ORG_ID,
         XX_P2P_PKG.XX_FND_EMP (WH.CREATED_BY) USER_NAME,
         NVL (
            NVL (XX_DO_LINER (OE.LINE_ID),
                 NVL (OE.CUSTOMER_JOB, OE.ATTRIBUTE1)),
            XX_DO_LINER123 (OE.ATTRIBUTE15))
            CUSTOMER_JOB,
         TP.ATTRIBUTE14 TP_REMARKS,
         TP.ATTRIBUTE6 delivery_person_mob_num,
         TP.NAME TRIP_NAME,
         OH.HEADER_ID DO_HEADER_ID,
         NVL (TP.ATTRIBUTE10, WH.TP_ATTRIBUTE5) DRIVER_NAME,
         TP.ATTRIBUTE11 DRIVER_PH,
         tp.ATTRIBUTE2 || '-' || tp.ATTRIBUTE3 VEHICLE_NO,
         XXPO_REQ_NO (OH.SOURCE_DOCUMENT_ID) req_no,
         NVL (XX_DO_HEADER (OH.header_ID), OH.ATTRIBUTE2) DOHEADER_NOTE,
         TYP.NAME
    FROM WSH_NEW_DELIVERIES_V WH,
         WSH_DLVY_DELIVERABLES_V WL,
         --WSH_DELIVERY_LINE_STATUS_V WSH,
         ORG_ORGANIZATION_DEFINITIONS OOD,
         HR_ORGANIZATION_UNITS_V HR,
         XX_OE_ORDER_HEADERS_V OH,
         XX_OE_ORDER_LINES_V OE,
         MTL_SYSTEM_ITEMS_KFV MTL,
         WSH_TRIP_DELIVERIES_V trf,
         WSH_TRIPS_V TP,
         XX_SALESREP_NAME_V SPN,
         XX_OE_TRANSACTION_TYPES_V TYP
   WHERE     WL.DELIVERY_DETAIL_ID <> 5686031
         AND WH.ORGANIZATION_ID = OOD.ORGANIZATION_ID
         AND WH.DELIVERY_ID = WL.DELIVERY_ID
         AND OH.HEADER_ID = OE.HEADER_ID
         AND TP.TRIP_ID = TRF.TRIP_ID
         AND WL.SOURCE_HEADER_ID = OH.HEADER_ID
         AND WL.SOURCE_LINE_ID = OE.LINE_ID
         AND SPN.ORG_ID = OH.ORG_ID
         --AND ( :P_USER IS NULL OR WH.CREATED_BY = :P_USER)
         AND OH.SALESREP_ID = SPN.SALESREP_ID
/*         AND TRUNC (OH.ORDERED_DATE) BETWEEN NVL (SPN.START_DATE_ACTIVE,
                                                  TRUNC (OH.ORDERED_DATE))
                                         AND NVL (SPN.END_DATE_ACTIVE,
                                                  TRUNC (OH.ORDERED_DATE))*/
         AND trf.DELIVERY_ID(+) = WL.DELIVERY_ID
         AND WL.INVENTORY_ITEM_ID = MTL.INVENTORY_ITEM_ID
         AND WL.ORGANIZATION_ID = MTL.ORGANIZATION_ID
         AND OH.ORDER_TYPE_ID = TYP.TRANSACTION_TYPE_ID
         AND OH.ORG_ID = :P_ORG
         AND ( :P_TRF IS NULL OR trf.TRIP_ID = :P_TRF)
         AND ( :P_DEL IS NULL OR WH.DELIVERY_ID = :P_DEL)
         AND ( :P_SPN IS NULL OR OH.SALESREP_ID = :P_SPN)
         and oh.order_number = '62400041'
         AND ( :P_DO_NO IS NULL OR OH.ORDER_NUMBER = :P_DO_NO)
         AND ( :P_CUSTOMER IS NULL OR OH.SOLD_TO_ORG_ID = :P_CUSTOMER)
   /*      AND TRUNC (WH.INITIAL_PICKUP_DATE) BETWEEN NVL (
                                                       :P_F_DT,
                                                       TRUNC (
                                                          WH.INITIAL_PICKUP_DATE))
                                                AND NVL (
                                                       :P_T_DT,
                                                       TRUNC (
                                                          WH.INITIAL_PICKUP_DATE))*/
         AND(:P_SO_NO IS NULL OR OH.QUOTE_NUMBER=:P_SO_NO)
         AND ( :P_SHIP_ORG IS NULL OR WL.ORGANIZATION_ID = :P_SHIP_ORG)
         AND ( :P_CAT IS NULL OR TYP.ATTRIBUTE2 = :P_CAT)
         --AND WH.STATUS_CODE IN ('CL', 'OP')
         --and WL.DELIVERY_DETAIL_ID=WSH.DELIVERY_DETAIL_ID
        -- AND WH.CREATED_BY = NVL ( :P_USER, WH.CREATED_BY)
         --AND WSH.SOURCE_CODE = 'OE'
         --AND OOD.ORGANIZATION_ID = HR.ORGANIZATION_ID
         and rownum < 100
GROUP BY OE.LINE_NUMBER,
         OH.ORG_ID,
         OE.SHIPMENT_NUMBER,
         OE.SHIP_FROM_ORG_ID,
         OE.SHIP_FROM_ORG_ID,
         OH.Attribute7 || ' ' || OH.Attribute8,
         TP.ATTRIBUTE11,
         tp.ATTRIBUTE2 || '-' || tp.ATTRIBUTE3,
         xx_com_pkg.GET_ORGANIZATION_CODE (OH.ORG_ID),
         OOD.ORGANIZATION_CODE,
         TP.ATTRIBUTE14,
         TP.ATTRIBUTE6,
         NVL (TP.ATTRIBUTE10, WH.TP_ATTRIBUTE5),
         SPN.RESOURCE_NAME,
         SPN.SOURCE_PHONE,
         OH.SOLD_TO || ', (' || OH.CUSTOMER_NUMBER || ')',
            OH.INVOICE_TO_ADDRESS1
         || ', '
         || OH.INVOICE_TO_ADDRESS2
         || ', '
         || OH.INVOICE_TO_ADDRESS3
         || ', '
         || OH.INVOICE_TO_ADDRESS4
         || ', '
         || OH.INVOICE_TO_ADDRESS5,
         DECODE (
            WH.ADDITIONAL_SHIPMENT_INFO,
            NULL, DECODE (
                     OH.SHIPPING_INSTRUCTIONS,
                     NULL,    OH.SHIP_TO_ADDRESS1
                           || ', '
                           || OH.SHIP_TO_ADDRESS2
                           || ', '
                           || OH.SHIP_TO_ADDRESS3
                           || ', '
                           || OH.SHIP_TO_ADDRESS4
                           || ', '
                           || OH.SHIP_TO_ADDRESS5,
                     OH.SHIPPING_INSTRUCTIONS),
            WH.ADDITIONAL_SHIPMENT_INFO),
         WH.NAME,
         TO_CHAR (WH.INITIAL_PICKUP_DATE, 'DD/MM/YYYY HH:MI:SS PM'),
         oh.ORDER_NUMBER,
         OH.ORDERED_DATE,
         WH.GLOBAL_ATTRIBUTE6,
         mtl.CONCATENATED_SEGMENTS,
         MTL.DESCRIPTION,                               --WL.ITEM_DESCRIPTION,
         WL.REQUESTED_QUANTITY_UOM,
         OH.SOLD_TO_ORG_ID,
         WH.CREATED_BY,
         OE.CUSTOMER_JOB,
         tp.ATTRIBUTE1,
         OH.SOURCE_DOCUMENT_ID,
         OOD.ORGANIZATION_CODE,
         OH.HEADER_ID,
         TP.NAME,
         OH.ATTRIBUTE2,
         OE.ATTRIBUTE1,
         OH.ATTRIBUTE11,
         TYP.NAME,
          NVL (
            NVL (XX_DO_LINER (OE.LINE_ID),
                 NVL (OE.CUSTOMER_JOB, OE.ATTRIBUTE1)),
            XX_DO_LINER123 (OE.ATTRIBUTE15)),
         NVL (XX_DO_HEADER (oh.header_id), OH.ATTRIBUTE2)
ORDER BY OE.LINE_NUMBER, OE.SHIPMENT_NUMBER