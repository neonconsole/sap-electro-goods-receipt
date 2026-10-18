*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZKOF6_D_MANUFACT................................*
DATA:  BEGIN OF STATUS_ZKOF6_D_MANUFACT              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZKOF6_D_MANUFACT              .
CONTROLS: TCTRL_ZKOF6_D_MANUFACT
            TYPE TABLEVIEW USING SCREEN '0002'.
*...processing: ZKOF6_D_ORDER_H.................................*
DATA:  BEGIN OF STATUS_ZKOF6_D_ORDER_H               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZKOF6_D_ORDER_H               .
CONTROLS: TCTRL_ZKOF6_D_ORDER_H
            TYPE TABLEVIEW USING SCREEN '0003'.
*...processing: ZKOF6_D_ORDER_I.................................*
DATA:  BEGIN OF STATUS_ZKOF6_D_ORDER_I               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZKOF6_D_ORDER_I               .
CONTROLS: TCTRL_ZKOF6_D_ORDER_I
            TYPE TABLEVIEW USING SCREEN '0004'.
*...processing: ZKOF6_V_PRODUCT.................................*
TABLES: ZKOF6_V_PRODUCT, *ZKOF6_V_PRODUCT. "view work areas
CONTROLS: TCTRL_ZKOF6_V_PRODUCT
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_ZKOF6_V_PRODUCT. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZKOF6_V_PRODUCT.
* Table for entries selected to show on screen
DATA: BEGIN OF ZKOF6_V_PRODUCT_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZKOF6_V_PRODUCT.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZKOF6_V_PRODUCT_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZKOF6_V_PRODUCT_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZKOF6_V_PRODUCT.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZKOF6_V_PRODUCT_TOTAL.

*.........table declarations:.................................*
TABLES: *ZKOF6_D_MANUFACT              .
TABLES: *ZKOF6_D_ORDER_H               .
TABLES: *ZKOF6_D_ORDER_I               .
TABLES: ZKOF6_D_MANUFACT               .
TABLES: ZKOF6_D_ORDER_H                .
TABLES: ZKOF6_D_ORDER_I                .
TABLES: ZKOF6_D_PRODUCT                .
TABLES: ZKOF6_D_PROD_T                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
