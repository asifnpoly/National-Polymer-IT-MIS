DECLARE
v___opening_zm_number               VARCHAR2(45):= '4458';
v___closing_zm_number               VARCHAR2(45):= '2648';
v___division	                    VARCHAR2(1000):= 'Division-8 (Door)';
v___zone                            VARCHAR2(450):= 'Gazipur';
v___product_code                    VARCHAR2(50):= '143';
v___org_id                          VARCHAR2(50):= '102';
v___opening_issue                   INTEGER;
v___closing_issue                   INTEGER;
v___backup_day                      VARCHAR2(100);
v__backup_table                     INTEGER;
v___backup_data                     INTEGER;
v___end_date_active                 DATE := TRUNC('30-APR-2024');
v__closing_view                     INTEGER;
v___max_combination_id              NUMBER;
v___new_combination_id              NUMBER;
o___resource_name                   VARCHAR2(3000):='Pulok Das,(4458)';
v___opening__person_number          INTEGER;
BEGIN
--CHECKING NEW ZM
SELECT COUNT(*)
INTO v___opening_issue
FROM XX_CUSTTERRSRZMDM_V 
WHERE zm_number= v___opening_zm_number       --'4458'
AND DIVISION= v___division           --'Division-8 (Door)'
AND ZONE like v___zone             -- 'Gazipur'
and PRODUCT_CODE in (v___product_code)  --143              --@
AND END_DATE_ACTIVE is null
AND ORG_ID = v___org_id;      --102

DBMS_OUTPUT.PUT_LINE('Opening Issue Checking: '||v___opening_issue);
--CHECKING EXISTING ZM
select count(*) 
INTO v___closing_issue
FROM XX_CUSTTERRSRZMDM c
where COMBINATION_ID in (
SELECT COMBINATION_ID FROM XX_CUSTTERRSRZMDM_V 
WHERE zm_number=v___closing_zm_number
AND DIVISION=v___division
AND ZONE like v___zone
and PRODUCT_CODE in (v___product_code)
AND END_DATE_ACTIVE is null
AND ORG_ID=v___org_id
and COMBINATION_ID=c.COMBINATION_ID
);

DBMS_OUTPUT.PUT_LINE('Closing Issue Checking: '||v___closing_issue);
SELECT TO_CHAR(SYSDATE,'DDMMYY')
INTO v___backup_day
FROM DUAL;

IF v___opening_issue = 0 THEN
    --BACKUP closing issue
    EXECUTE IMMEDIATE 'CREATE TABLE XX_CUSTTERRSRZMDM_'||v___backup_day||' AS ('||
   'select *'||' '||
   'FROM XX_CUSTTERRSRZMDM c'||' '||
   'where COMBINATION_ID in ('||' '||
   'SELECT COMBINATION_ID FROM XX_CUSTTERRSRZMDM_V'||' '|| 
   'WHERE zm_number='''||v___closing_zm_number||''' '||
   'AND DIVISION='''||v___division||''' '||
   'AND ZONE like '''||v___zone||''' '||
   'and PRODUCT_CODE in ('''||v___product_code||''') '||
   'AND END_DATE_ACTIVE is null'||' '||
   'AND ORG_ID='''||v___org_id||''' '||
   'and COMBINATION_ID=c.COMBINATION_ID))';
   
   --CHECKING BACKUP TABLE CONFIRMATION
    SELECT COUNT(table_name) 
    INTO v__backup_table
    FROM user_tables 
    WHERE table_name LIKE '%XX_CUSTTERRSRZMDM_'||v___backup_day||'%';
    --CHECKING BACKUP DATA CONFIRMATION
    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM XX_CUSTTERRSRZMDM_'||v___backup_day INTO v___backup_data;
    IF v__backup_table = 1 AND v___backup_data > 0 THEN
    --BACKUP IS DONE
    DBMS_OUTPUT.PUT_LINE('BACKUP TABLE COUNT: '||v__backup_table);
    DBMS_OUTPUT.PUT_LINE('BACKUP DATA TOTAL: '||v___backup_data);
    --CLOSING
            DECLARE
            CURSOR C1 IS 
            SELECT * FROM XX_CUSTTERRSRZMDM_V 
            WHERE zm_number = v___closing_zm_number
            AND DIVISION=v___division
            AND ZONE like v___zone
            and PRODUCT_CODE in (v___product_code)
            AND END_DATE_ACTIVE is null
            AND ORG_ID=v___org_id;
            BEGIN
                FOR I IN C1 LOOP
                UPDATE  XX_CUSTTERRSRZMDM
                SET END_DATE_ACTIVE = v___end_date_active,
                TRACK_ZM_ID=i.zm_number,
                UPD_DATE=trunc(SYSDATE)
                WHERE COMBINATION_ID=I.COMBINATION_ID
                AND ZM_NUMBER=I.ZM_NUMBER
                AND PRODUCT_NAME = i.PRODUCT_NAME
                AND END_DATE_ACTIVE IS NULL
                AND ORG_ID = v___org_id;
                END LOOP;
            END;
            DBMS_OUTPUT.PUT_LINE('Closed');
            --OPENING
            --CHECKING DATA ROWS ARE SAME
            --FROM VIEW
            SELECT COUNT(*)
            INTO v__closing_view 
            FROM XX_CUSTTERRSRZMDM_V 
            WHERE zm_number = v___closing_zm_number
            AND DIVISION = v___division
            AND ZONE like v___zone
            and PRODUCT_CODE in (v___product_code)
            AND END_DATE_ACTIVE is null
            AND ORG_ID = v___org_id;
                    IF v___backup_data = v__closing_view THEN
                        --PROCEED TO OPENNING
                        select MAX (COMBINATION_ID)
                        INTO v___max_combination_id 
                        FROM  XX_CUSTTERRSRZMDM;
                        --GETTING OPENING ISSUE DATA
                        SELECT COUNT(*)
                        INTO v___opening__person_number
                        FROM XX_SALESREP_NAME_V
                        where ORG_ID = v___org_id
                        AND RESOURCE_NAME = o___resource_name;
                        IF v___opening__person_number = 1 THEN
                        FOR i IN 1..73 LOOP
                        v___new_combination_id := v___max_combination_id + i;
                        INSERT INTO XX_CUSTTERRSRZMDM(COMBINATION_ID
                                                        ,CUSTOMER_ID
                                                        ,ORG_ID
                                                        ,TERRITORY_ID
                                                        ,PRODUCT_CODE
                                                        ,PRODUCT_NAME
                                                        ,SALESREP_ID
                                                        ,SALESREP_NUMBER
                                                        ,SALESREP_NAME
                                                        ,ZM_ID
                                                        ,ZM_NUMBER
                                                        ,ZM_NAME
                                                        ,DM_ID
                                                        ,DM_NUMBER
                                                        ,DM_NAME
                                                        ,START_DATE_ACTIVE
                                                        ,END_DATE_ACTIVE
                                                        ,CREATED_BY
                                                        ,CREATION_DATE
                                                        ,LAST_UPDATED_BY
                                                        ,LAST_UPDATE_DATE
                                                        ,LAST_UPDATE_LOGIN
                                                        ,ORDER_TYPE_ID
                                                        ,ORDER_TYPE_NAME
                                                        ,SM_NUMBER
                                                        ,SM_NAME
                                                        ,NSM_NUMBER
                                                        ,NSM_NAME
                                                        ,PROD_GROUP
                                                        ,SM_ID
                                                        ,NSM_ID
                                                        ,ATTRIBUTE11)
                        VALUES(D);
                        END LOOP;
                    ELSE 
                    NULL;   --NO OPENING SALES PERSON EXISTS
                    END IF;
                    ELSE
                    NULL;   --NO MATCH BETWEEN CLOSING DATA AND BACKUP DATA
            --OPENNED
    ELSE NULL;  --NO TABLE NO BACKUP DATA
    END IF;
ELSE
NULL;   --OPENING ISSUE DATA ALREADY IS IN TABLE UNEXPECTADELY
END IF;

END;