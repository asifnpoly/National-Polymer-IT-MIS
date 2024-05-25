select XX.PRIMARY_UOM_CODE,
    XX.ORG,
    XX.NAME,
    XX.ITEM_CODE,
    XX.ITEM_DESCRIPTION,
    XX.INVENTORY_ITEM_ID,
    XX.ORGANIZATION_ID,
    :P_SEG1 MAJOR_CAT,
    :P_SEG2 MAJOR_SUB_CAT,
    :P_SEG3 MINOR_CAT,
    :P_PERIOD_CODE START_DATE,
    SUM(NVL(XX.OPN_QTY,0)) OPN_QTY,
    SUM(NVL(XX.RCV_QTY,0)) RCV_QTY,
    SUM(NVL(XX.ISU_QTY,0)) ISU_QTY,
    SUM(NVL(XX.OPN_QTY,0) + NVL(XX.RCV_QTY,0) - NVL(XX.ISU_QTY,0)) CLOSING_QTY
From 
--Opening--
------------------------------------------------
((SELECT   
    kf.PRIMARY_UOM_CODE,
    OOD.ORGANIZATION_CODE ORG,
    ou.NAME,
    KF.CONCATENATED_SEGMENTS ITEM_CODE,
    KF.DESCRIPTION ITEM_DESCRIPTION,
    MMT.INVENTORY_ITEM_ID,
    MMT.ORGANIZATION_ID,
    OP.END_DATE,
   SUM(PRIMARY_QUANTITY) opn_qty,
    --xx_prior_period_balance_cs(mmt.organization_id, mmt.inventory_item_id, OP.START_DATE, OP.END_DATE, 2) opn_rate , 
        to_number(0) rcv_qty,
        to_number(0) isu_qty
FROM   MTL_MATERIAL_TRANSACTIONS MMT,
    MTL_SYSTEM_ITEMS_KFV KF,
    APPS.ORG_ORGANIZATION_DEFINITIONS OOD,
    APPS.hr_operating_units ou,
    APPS.MTL_ITEM_CATEGORIES MCI,
    APPS.MTL_CATEGORIES MC,
    CM_CLDR_DTL OP   
WHERE  MMT.TRANSACTION_ACTION_ID != 24
    and (MMT.LOGICAL_TRANSACTION=2 OR MMT.LOGICAL_TRANSACTION IS NULL ) 
     and MMT.ORGANIZATION_ID = OOD.ORGANIZATION_ID
     AND MCI.INVENTORY_ITEM_ID=KF.INVENTORY_ITEM_ID
     and MCI.ORGANIZATION_ID = OOD.ORGANIZATION_ID
     AND MCI.CATEGORY_ID=MC.CATEGORY_ID
     and mmt.transaction_TYPE_ID NOT IN (SELECT transaction_TYPE_ID FROM MTL_TRANSACTION_TYPES
                                                                WHERE TRANSACTION_ACTION_ID IN (2,28))
    AND MMT.TRANSACTION_TYPE_ID not in (52,112)
     AND MC.STRUCTURE_ID=101
     AND MC.SEGMENT1=NVL(:P_SEG1,MC.SEGMENT1)
     AND MC.SEGMENT2=NVL(:P_SEG2,MC.SEGMENT2)
     AND MC.SEGMENT3=NVL(:P_SEG3,MC.SEGMENT3)
     and ou.ORGANIZATION_ID=ood.OPERATING_UNIT
     and ood.OPERATING_UNIT=nvl(:p_ou,ood.OPERATING_UNIT)
    AND MMT.ORGANIZATION_ID = KF.ORGANIZATION_ID
    AND MMT.INVENTORY_ITEM_ID = KF.INVENTORY_ITEM_ID
    AND ood.organization_id = NVL(:p_org, mmt.organization_id)
    and mmt.inventory_item_id = nvl(:P_ITEM_ID, mmt.inventory_item_id)
    and TRUNC (mmt.transaction_date)<OP.START_DATE
    AND OP.PERIOD_CODE = :P_PERIOD_CODE
group by 
    kf.PRIMARY_UOM_CODE,
    OOD.ORGANIZATION_CODE,
    ou.NAME,
    KF.CONCATENATED_SEGMENTS,
    KF.DESCRIPTION,
    MMT.INVENTORY_ITEM_ID,
    MMT.ORGANIZATION_ID,
    OP.START_DATE, 
    OP.END_DATE
)
 union all
  --current_transaction
(SELECT   
    kf.PRIMARY_UOM_CODE,
    OOD.ORGANIZATION_CODE ORG,
    ou.NAME,
    --oh.COMPLEX_NAME,
    KF.CONCATENATED_SEGMENTS ITEM_CODE,
    KF.DESCRIPTION ITEM_DESCRIPTION,
    MMT.INVENTORY_ITEM_ID,
    MMT.ORGANIZATION_ID,
    OP.END_DATE,
    to_number(0) opn_qty,
    ----------------RCV_QTY
      sum((case
        when MMT.PRIMARY_QUANTITY>0 and MMT.transaction_type_id not in (15,114,113,42,43) --Production Floor Return
            then nvl(MMT.PRIMARY_QUANTITY,0)
        else 0
        end)+
        (case
        when MMT.transaction_type_id in (36,71,1003,17,72) --Return to Vendor and Receive Adj
            then nvl(MMT.PRIMARY_QUANTITY,0)
        else 0
        end)) rcv_qty,
        -----------
        --------
        abs(sum(abs(case
            when MMT.PRIMARY_QUANTITY<0 and MMT.transaction_type_id not in (36,71,1003,17,72)
                then nvl(MMT.PRIMARY_QUANTITY,0)
            else 0
        end)
        -
        case
            when MMT.transaction_type_id in (114,113,42,43)
                            then nvl(MMT.PRIMARY_QUANTITY,0)
            else 0
        end
        -
        case
            when MMT.transaction_type_id in (15)
                            then nvl(MMT.PRIMARY_QUANTITY,0)
            else 0
        end
        )) isu_qty
        ------------------
FROM   MTL_MATERIAL_TRANSACTIONS MMT,
    MTL_SYSTEM_ITEMS_KFV KF,
    APPS.ORG_ORGANIZATION_DEFINITIONS OOD,
    APPS.hr_operating_units ou,
    APPS.MTL_ITEM_CATEGORIES MCI,
    APPS.MTL_CATEGORIES MC,
    CM_CLDR_DTL OP      
WHERE   MMT.TRANSACTION_ACTION_ID != 24
    AND MMT.TRANSACTION_TYPE_ID not in (52,112)
    and mmt.transaction_TYPE_ID NOT IN (SELECT transaction_TYPE_ID FROM MTL_TRANSACTION_TYPES
                                                                WHERE TRANSACTION_ACTION_ID IN (2,28))
    and (MMT.LOGICAL_TRANSACTION=2 OR MMT.LOGICAL_TRANSACTION IS NULL ) 
     and MMT.ORGANIZATION_ID = OOD.ORGANIZATION_ID
     AND MCI.INVENTORY_ITEM_ID=KF.INVENTORY_ITEM_ID
     and MCI.ORGANIZATION_ID = OOD.ORGANIZATION_ID
     AND MCI.CATEGORY_ID=MC.CATEGORY_ID
     AND MC.STRUCTURE_ID=101
     AND MC.SEGMENT1=NVL(:P_SEG1,MC.SEGMENT1)
     AND MC.SEGMENT2=NVL(:P_SEG2,MC.SEGMENT2)
     AND MC.SEGMENT3=NVL(:P_SEG3,MC.SEGMENT3)
     and ou.ORGANIZATION_ID=ood.OPERATING_UNIT
     and ood.OPERATING_UNIT=nvl(:p_ou,ood.OPERATING_UNIT)
    AND MMT.ORGANIZATION_ID = KF.ORGANIZATION_ID
    AND MMT.INVENTORY_ITEM_ID = KF.INVENTORY_ITEM_ID
    AND ood.organization_id = NVL(:p_org, mmt.organization_id)
    AND TRUNC (mmt.transaction_date) BETWEEN OP.START_DATE AND OP.END_DATE
    and mmt.inventory_item_id = nvl(:P_ITEM_ID, mmt.inventory_item_id)
    AND OP.PERIOD_CODE = :P_PERIOD_CODE
  group by 
    kf.PRIMARY_UOM_CODE,
    OOD.ORGANIZATION_CODE,
    ou.NAME,
    KF.CONCATENATED_SEGMENTS,
    KF.DESCRIPTION,
    MMT.INVENTORY_ITEM_ID,
    MMT.ORGANIZATION_ID,
    OP.END_DATE
  )
  )XX
  ------------------------------------
WHERE ((NVL(XX.OPN_QTY,0)) + (NVL(XX.RCV_QTY,0)) + (NVL(XX.ISU_QTY,0)))<>0
GROUP BY XX.PRIMARY_UOM_CODE,
    XX.ORG,
    XX.NAME,
    XX.ITEM_CODE,
    XX.ITEM_DESCRIPTION,
    XX.INVENTORY_ITEM_ID,
    XX.ORGANIZATION_ID,
    XX.END_DATE
    ORDER BY XX.ORG,
        XX.ITEM_CODE ASC;