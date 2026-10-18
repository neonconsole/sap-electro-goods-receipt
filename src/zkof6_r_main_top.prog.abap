*&---------------------------------------------------------------------*
*& Include          ZKOF6_R_MAIN_TOP
*&---------------------------------------------------------------------*

TABLES:
  sscrfields,
  zkof6_s_order,
  zkof6_s_product,
  zkof6_s_receipt.

DATA:
  gv_0200_ucomm         TYPE sy-ucomm,
  gv_applied_order_id   TYPE zkof6_order_id,
  gv_item_no            TYPE zkof6_item_no,
  gv_checked_product_id TYPE zkof6_product_id,
  gv_checked_product_name TYPE zkof6_product_name,
  gv_order_status       TYPE zkof6_order_status,
  gv_added_item_count   TYPE i,
  gt_receipt_items      TYPE zkof6_t_recp_i,
  gs_receipt_item       TYPE zkof6_d_recp_i.
