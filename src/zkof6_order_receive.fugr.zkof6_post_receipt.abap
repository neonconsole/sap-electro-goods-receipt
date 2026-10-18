FUNCTION ZKOF6_POST_RECEIPT.
*"----------------------------------------------------------------------
*"*"Update Function Module:
*"
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IT_RECEIPT_ITEMS) TYPE  ZKOF6_T_RECP_I
*"     VALUE(IS_RECEIPT) TYPE  ZKOF6_S_RECEIPT
*"     VALUE(IV_ORDER_STATUS) TYPE  ZKOF6_ORDER_STATUS
*"----------------------------------------------------------------------

INSERT zkof6_d_recp_h
FROM is_receipt.

IF sy-subrc <> 0.
  MESSAGE 'Error occured during posting receipt.'(m01) TYPE 'A'.
ENDIF.

INSERT zkof6_d_recp_i
FROM TABLE it_receipt_items.

IF sy-subrc <> 0.
  MESSAGE 'Error occured during posting receipt.'(m01) TYPE 'A'.
ENDIF.

UPDATE zkof6_d_order_h
  SET status = @iv_order_status
  WHERE order_id = @is_receipt-order_id.

IF sy-subrc <> 0.
  MESSAGE 'Error occured during posting receipt.'(m01) TYPE 'A'.
ENDIF.

ENDFUNCTION.
