--inventory
SELECT * FROM MTL_SYSTEM_ITEMS_B WHERE SEGMENT1 = 'REJ' AND SEGMENT2 = 'HP' AND SEGMENT3 = '708'; --WHERE TO FIND ITEM'S ADD TO INVENTORY FOR BUY/MAKE
/
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------PURCHASE REQUISITION
--go to purchase requisitions
--purchase requisiton 3tables
--11841518  PR
SELECT * FROM PO_REQUISITION_HEADERS_ALL WHERE SEGMENT1 = '11841518';       --requision name : hello world 11841518 REQNO
/
SELECT * FROM PO_REQUISITION_LINES_ALL WHERE REQUISITION_HEADER_ID = '1044496'; --itme mirror clip qty 7 price 20
/
SELECT * FROM PO_REQ_DISTRIBUTIONS_ALL WHERE REQUISITION_LINE_ID = '1707321';
/
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------REQUEST FOR QUATATION
--go to RFQ request for qotation; add supplier payment terms currency etc
--21800002  
SELECT * FROM PO_HEADERS_ALL WHERE SEGMENT1 = '21800002' AND TYPE_LOOKUP_CODE = 'RFQ'; --RFQ NO --HEADERID 721792
/
SELECT * FROM PO_LINES_ALL WHERE PO_HEADER_ID = '721792'; --LINEID 888250
/
SELECT * FROM PO_RFQ_VENDORS WHERE PO_HEADER_ID = '721792';
/
SELECT * FROM PO_LINE_LOCATIONS_ALL WHERE PO_LINE_ID = '888250'; --SHIPMENT DETAILS
/
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------QUATATION
--The quotation is a formal document submitted by a supplier in response to the RFQ
--go to qotation / or create it from RFQ by select:  tools > copy document > action > create from headers, site| select supplier
--31800001                  31800002
SELECT * FROM PO_HEADERS_ALL WHERE SEGMENT1 = '31800001' AND TYPE_LOOKUP_CODE = 'QUOTATION'; --RFQ NO --HEADERID 721793
/
SELECT * FROM PO_LINES_ALL WHERE PO_HEADER_ID = '721793'; --LINEID 888251
/
SELECT * FROM PO_LINE_LOCATIONS_ALL WHERE PO_LINE_ID = '888251'; --SHIPMENT DETAILS
/
--make RFQ status ACTIVE instead of IN PROCESS and save
--make QUOTATION status ACTIVE instead of IN PROCESS and save
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------PURCHASE ORDER
--go to purchase order
--41829484
--acc 110.1010306.0000.00.0000.000.0000.000
SELECT * FROM PO_HEADERS_ALL WHERE SEGMENT1 = '41829484' ; --PO NO --HEADERID 41829484
/
SELECT * FROM PO_LINES_ALL WHERE PO_HEADER_ID = '721795'; --LINEID 888253
/
SELECT * FROM PO_LINE_LOCATIONS_ALL WHERE PO_LINE_ID = '888253'; --SHIPMENT DETAILS LINE  LOCATION ID 1026649
/
SELECT * FROM PO_DISTRIBUTIONS_ALL WHERE LINE_LOCATION_ID = '1026649';
/
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------RECEIPT
--receiving
--go to receipt
--123063
SELECT * FROM RCV_SHIPMENT_HEADERS WHERE RECEIPT_NUM = '123063'; --SHIPMENT HEADER ID 1024562
/
SELECT * FROM RCV_SHIPMENT_LINES WHERE SHIPMENT_HEADER_ID = '1024562';      --QYT7 ITEM MIRRORCLIP ETC
/
SELECT * FROM RCV_TRANSACTIONS WHERE SHIPMENT_HEADER_ID = '1024562';        --po header id / po line id
/

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------INVOICE
--open period: accounting > control payables period
--Accounts Payable
--Invoice
SELECT * FROM AP_INVOICES_ALL WHERE INVOICE_NUM = 'INV454'; --INV ID 1221879
/
SELECT * FROM AP_INVOICE_LINES_ALL WHERE INVOICE_ID = '1221879';
/
SELECT * FROM AP_INVOICE_DISTRIBUTIONS_ALL WHERE INVOICE_ID = '1221879' AND INVOICE_LINE_NUMBER= '1'; --getting ACCOUNTING_EVENT_ID after gl post 29574438
/
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------INVOICE ACCOUNTING
--validate invoice
--creating accounting : it shifts sub ledger and gL module
--29574438
SELECT * FROM XLA_EVENTS WHERE EVENT_ID = '29574438';
/
SELECT * FROM XLA_AE_HEADERS WHERE EVENT_ID = '29574438';   --accounting base table 64934571 DESCRIPTION
/
SELECT * FROM XLA_AE_LINES WHERE AE_HEADER_ID = '64934571';     --DEBIT CREDIT AMOUNT -- GL_SL_LINK_ID 163503307 LIABILITY 163503306 ACCRUAL
/
SELECT * FROM XLA_DISTRIBUTION_LINKS WHERE AE_HEADER_ID = '64934571';
/
SELECT * FROM GL_IMPORT_REFERENCES WHERE GL_SL_LINK_ID IN (163503307,163503306); --351371 JE HEADER ID
/
--GENERAL LEDGER
--341768 JE_BATCH_ID| 351371 JE_HEADER_ID | 1 2 JE_LINE_ID
--351371
SELECT * FROM GL_JE_HEADERS WHERE JE_HEADER_ID = '351371';
/
SELECT * FROM GL_JE_LINES WHERE JE_HEADER_ID = '351371';
/
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------PAYMENT
--go for payment
--139812 DOCUMENT NO
SELECT * FROM AP_INVOICE_PAYMENTS_ALL WHERE INVOICE_ID = '1221879';      --LINK TABLE OF INVOICE<--> PAYMENT CHECK_ID 1216943   ACCOUNTING_EVENT_ID 29574439
/
SELECT * FROM AP_CHECKS_ALL WHERE CHECK_NUMBER = '139812';  --PAYMENT BASE TABLE 
/
--ACCOUNTING
--29574439
SELECT * FROM XLA_EVENTS WHERE EVENT_ID = '29574439';
/
SELECT * FROM XLA_AE_HEADERS WHERE EVENT_ID = '29574439';   --accounting base table 64934572 DESCRIPTION
/
SELECT * FROM XLA_AE_LINES WHERE AE_HEADER_ID = '64934572';     --DEBIT CREDIT AMOUNT -- GL_SL_LINK_ID 163503308 LIABILITY 163503309 CASH CLEARING
/
SELECT * FROM XLA_DISTRIBUTION_LINKS WHERE AE_HEADER_ID = '64934572';
/
SELECT * FROM GL_IMPORT_REFERENCES WHERE GL_SL_LINK_ID IN (163503308,163503309); --351373 JE HEADER ID
/
SELECT * FROM GL_JE_HEADERS WHERE JE_HEADER_ID = '351373';
/
SELECT * FROM GL_JE_LINES WHERE JE_HEADER_ID = '351373';    --in general ledger module : journal> enter> journal name: NAME COLUMN: Jan-24 Payments BDT
/



/*
----------------------------------------------------------------Inventory
MTL_SYSTEM_ITEMS_B

----------------------------------------------------------------Requisiton
PO_REQUISITION_HEADERS_ALL
PO_REQUISITION_LINES_ALL
PO_REQ_DISTRIBUTIONS_ALL

----------------------------------------------------------------Purchase Order
PO_HEADERS_ALL
PO_LINES_ALL
PO_RFQ_VENDORS
PO_LINE_LOCATIONS_ALL
PO_DISTRIBUTIONS_ALL

----------------------------------------------------------------Purchase Receive
RCV_SHIPMENT_HEADERS
RCV_SHIPMENT_LINES
RCV_TRANSACTIONS

----------------------------------------------------------------Invoice
AP_INVOICES_ALL
AP_INVOICE_LINES_ALL
AP_INVOICE_DISTRIBUTIONS_ALL

----------------------------------------------------------------Accounting
XLA_EVENTS
XLA_AE_HEADERS
XLA_AE_LINES
XLA_DISTRIBUTION_LINKS
GL_IMPORT_REFERENCES
GL_JE_HEADERS
GL_JE_LINES

----------------------------------------------------------------Payments
AP_INVOICE_PAYMENTS_ALL
AP_CHECKS_ALL

----------------------------------------------------------------Accounting
XLA_EVENTS
XLA_AE_HEADERS
XLA_AE_LINES
XLA_DISTRIBUTION_LINKS
GL_IMPORT_REFERENCES
GL_JE_HEADERS
GL_JE_LINES

*/