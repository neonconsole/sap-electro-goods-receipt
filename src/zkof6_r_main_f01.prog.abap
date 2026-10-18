*&---------------------------------------------------------------------*
*& Include          ZKOF6_R_MAIN_F01
*&---------------------------------------------------------------------*

FORM handle_apply.
  PERFORM clear_product_data.

  SELECT SINGLE *
    FROM zkof6_d_order_h AS o
    WHERE o~order_id = @zkof6_s_order-order_id
    INTO CORRESPONDING FIELDS OF @zkof6_s_order.

  IF sy-subrc <> 0.
    MESSAGE 'Order does not exist'(m01) TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  gv_applied_order_id = zkof6_s_order-order_id.
  zkof6_s_receipt-order_id = gv_applied_order_id.
  zkof6_s_receipt-receipt_date = sy-datum.
  zkof6_s_receipt-created_by = sy-uname.
  zkof6_s_receipt-mandt = sy-mandt.
ENDFORM.

FORM handle_checki.

  DATA:
    lv_search_id   TYPE zkof6_s_product-product_id,
    lv_search_name TYPE zkof6_s_product-product_name.

  IF gv_applied_order_id IS INITIAL.
    MESSAGE 'You need to apply order first'(m02) TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  IF gv_checked_product_id IS NOT INITIAL
      AND zkof6_s_product-product_id <> gv_checked_product_id.
    lv_search_id = zkof6_s_product-product_id.
  ELSEIF gv_checked_product_name IS NOT INITIAL
    AND zkof6_s_product-product_name <> gv_checked_product_name.
    lv_search_name = zkof6_s_product-product_name.
  ELSEIF zkof6_s_product-product_id IS NOT INITIAL.
    lv_search_id = zkof6_s_product-product_id.
  ELSEIF zkof6_s_product-product_name IS NOT INITIAL.
    lv_search_name = zkof6_s_product-product_name.
  ELSE.
    MESSAGE 'Enter product ID or name'(m21) TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  CLEAR zkof6_s_product.

  SELECT SINGLE
    oi~product_id,
    oi~ordered_quantity,
    p~unit,
    p~warehouse_type,
    pt~product_name,
    pt~description
    FROM zkof6_d_order_i AS oi
    INNER JOIN zkof6_d_product AS p
      ON oi~product_id = p~product_id
    INNER JOIN zkof6_d_prod_t AS pt
      ON oi~product_id = pt~product_id
    WHERE ( ( @lv_search_id IS NOT INITIAL AND oi~product_id = @lv_search_id )
          OR ( @lv_search_name IS NOT INITIAL AND pt~product_name = @lv_search_name ) )
    AND oi~order_id = @gv_applied_order_id
    AND pt~langu = @sy-langu
    INTO CORRESPONDING FIELDS OF @zkof6_s_product.

  IF sy-subrc <> 0.
    MESSAGE 'Product does not belong to the order or does not exist'(m03) TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  gv_checked_product_id = zkof6_s_product-product_id.
  gv_checked_product_name = zkof6_s_product-product_name.

  SELECT SUM( ri~quantity )
    FROM zkof6_d_recp_i AS ri
    INNER JOIN zkof6_d_recp_h AS rh
      ON ri~receipt_id = rh~receipt_id
    WHERE rh~order_id = @gv_applied_order_id
    AND ri~product_id = @zkof6_s_product-product_id
    INTO @zkof6_s_product-received_quantity.

  zkof6_s_product-remaining_quantity = zkof6_s_product-ordered_quantity - zkof6_s_product-received_quantity.

  MESSAGE 'Product validated successfully'(m04) TYPE 'S'.

ENDFORM.

FORM handle_addi.
  IF gv_applied_order_id IS INITIAL.
    MESSAGE 'You need to apply order first'(m02) TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  IF gv_checked_product_id <> zkof6_s_product-product_id.
    MESSAGE 'You need to check current item first'(m05) TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  IF zkof6_s_product-item_quantity IS INITIAL.
    MESSAGE 'Item quantity must be higher than zero'(m06) TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  IF zkof6_s_product-item_quantity > zkof6_s_product-remaining_quantity.
    MESSAGE 'Added item quantity is higher than remaining item quantity'(m07) TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  gv_item_no = gv_item_no + 10.

  gs_receipt_item-receipt_id = zkof6_s_receipt-receipt_id.
  gs_receipt_item-product_id = zkof6_s_product-product_id.
  gs_receipt_item-unit = zkof6_s_product-unit.
  gs_receipt_item-quantity = zkof6_s_product-item_quantity.
  gs_receipt_item-item_no = gv_item_no.
  gs_receipt_item-mandt = sy-mandt.
  APPEND gs_receipt_item TO gt_receipt_items.
  gv_added_item_count = lines( gt_receipt_items ).
  CLEAR gs_receipt_item.
  CLEAR gv_checked_product_id.
  MESSAGE 'Item added successfully. Submit the receipt to save the data'(m08) TYPE 'S'.
ENDFORM.

FORM handle_submit.

  IF gv_applied_order_id IS INITIAL.
    MESSAGE 'You need to apply order first'(m02) TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  IF zkof6_s_order-status = 'COMPLETED'.
    MESSAGE 'Order is already completed'(m09) TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  IF gt_receipt_items IS INITIAL.
    MESSAGE 'You need to add items to the receipt'(m10) TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  PERFORM set_locks.

  DATA lv_valid TYPE abap_bool.
  PERFORM quantity_validation CHANGING lv_valid.

  IF lv_valid = abap_false.
    PERFORM unlock.
    PERFORM clear_all_data.
    LEAVE TO SCREEN sy-dynnr.
  ENDIF.

  PERFORM calculate_order_status.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr        = '01'
      object             = 'ZKOF6_REC'
    IMPORTING
      number             = zkof6_s_receipt-receipt_id
    EXCEPTIONS
      interval_not_found = 1
      interval_overflow  = 2
      OTHERS             = 3.

  IF sy-subrc = 1.
    MESSAGE 'Receipt ID interval not found'(m11) TYPE 'A'.
  ELSEIF sy-subrc = 2.
    MESSAGE 'Receipt ID interval overflown'(m12) TYPE 'A'.
  ELSEIF sy-subrc <> 0.
    MESSAGE 'Error during receipt ID generation'(m13) TYPE 'A'.
  ENDIF.



  LOOP AT gt_receipt_items ASSIGNING FIELD-SYMBOL(<fs_item>).
    <fs_item>-receipt_id = zkof6_s_receipt-receipt_id.
  ENDLOOP.

  CALL FUNCTION 'ZKOF6_POST_RECEIPT' IN UPDATE TASK
    EXPORTING
      it_receipt_items = gt_receipt_items
      is_receipt       = zkof6_s_receipt
      iv_order_status  = gv_order_status.

  COMMIT WORK.

  PERFORM unlock.

  DATA(lv_msg) = |{ TEXT-m14 }{ zkof6_s_receipt-receipt_id }|.
  MESSAGE lv_msg TYPE 'S'.
*  MESSAGE |Receipt posted successfully. Receipt ID = { zkof6_s_receipt-receipt_id }| TYPE 'S'.

  PERFORM clear_all_data.

ENDFORM.

FORM quantity_validation CHANGING cv_valid TYPE abap_bool.
  cv_valid = abap_true.

  DATA:
    lt_receipt_items_copy       TYPE TABLE OF zkof6_d_recp_i,
    lv_currently_added_quantity TYPE zkof6_d_recp_i-quantity.

  lt_receipt_items_copy = gt_receipt_items.

  LOOP AT lt_receipt_items_copy ASSIGNING FIELD-SYMBOL(<fs_product>).
    SELECT SINGLE ordered_quantity
      FROM zkof6_d_order_i
      WHERE order_id = @gv_applied_order_id
        AND product_id = @<fs_product>-product_id
      INTO @DATA(lv_ordered_quantity).

    SELECT SUM( ri~quantity )
        FROM zkof6_d_recp_i AS ri
        INNER JOIN zkof6_d_recp_h AS rh
          ON ri~receipt_id = rh~receipt_id
        WHERE rh~order_id = @gv_applied_order_id
        AND ri~product_id = @<fs_product>-product_id
        INTO @DATA(lv_received_quantity).

    CLEAR lv_currently_added_quantity.

    LOOP AT lt_receipt_items_copy ASSIGNING FIELD-SYMBOL(<fs_product2>)
      WHERE product_id = <fs_product>-product_id.
      lv_currently_added_quantity = lv_currently_added_quantity + <fs_product2>-quantity.
    ENDLOOP.

    IF lv_received_quantity + lv_currently_added_quantity > lv_ordered_quantity.
      MESSAGE 'Added items quantity is higher than remaining quantity'(m15) TYPE 'S' DISPLAY LIKE 'E'.
      cv_valid = abap_false.
      EXIT.
    ENDIF.

  ENDLOOP.

ENDFORM.

FORM calculate_order_status.

  DATA:
        lv_total_added_quantity TYPE zkof6_d_recp_i-quantity.

  CLEAR lv_total_added_quantity.

  SELECT SUM( ordered_quantity )
    FROM zkof6_d_order_i
    WHERE order_id = @gv_applied_order_id
    INTO @DATA(lv_total_ordered_quantity).

  SELECT SUM( quantity )
    FROM zkof6_d_recp_i AS ri
    INNER JOIN zkof6_d_recp_h AS rh
    ON ri~receipt_id = rh~receipt_id
    WHERE rh~order_id = @gv_applied_order_id
    INTO @DATA(lv_total_received_quantity).

  LOOP AT gt_receipt_items ASSIGNING FIELD-SYMBOL(<fs_product_total>).

    lv_total_added_quantity = lv_total_added_quantity + <fs_product_total>-quantity.

  ENDLOOP.

  IF lv_total_ordered_quantity = lv_total_added_quantity + lv_total_received_quantity.
    gv_order_status = 'COMPLETED'.
  ELSE.
    gv_order_status = 'PARTIAL'.
  ENDIF.

ENDFORM.

FORM set_locks.
  CALL FUNCTION 'ENQUEUE_EZKOF6_ORDER'
    EXPORTING
      mode_zkof6_d_order_h = 'E'
      mandt                = sy-mandt
      order_id             = gv_applied_order_id
      _scope               = '2'
    EXCEPTIONS
      foreign_lock         = 1
      system_failure       = 2
      OTHERS               = 3.
  IF sy-subrc = 1.
    MESSAGE 'Order is currently locked by another user'(m20) TYPE 'S' DISPLAY LIKE 'W'.
    LEAVE TO SCREEN sy-dynnr.
  ELSEIF sy-subrc <> 0.
    MESSAGE 'Error during setting a lock'(m16) TYPE 'A'.
  ENDIF.
ENDFORM.

FORM unlock.
  CALL FUNCTION 'DEQUEUE_EZKOF6_ORDER'
    EXPORTING
      mode_zkof6_d_order_h = 'E'
      mandt                = sy-mandt
      order_id             = gv_applied_order_id
      _scope               = '2'.
ENDFORM.

FORM clear_all_data.
  CLEAR zkof6_s_order.
  PERFORM clear_product_data.
ENDFORM.

FORM clear_product_data.
  CLEAR zkof6_s_receipt.
  CLEAR zkof6_s_product.
  CLEAR gt_receipt_items.
  CLEAR gv_checked_product_id.
  CLEAR gv_item_no.
  CLEAR gv_applied_order_id.
  CLEAR gv_added_item_count.
ENDFORM.

FORM call_maintenance_view USING lv_view_name.
  CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
    EXPORTING
      action    = 'U'
      view_name = lv_view_name
    EXCEPTIONS
      OTHERS    = 1.
  IF sy-subrc <> 0.
    MESSAGE 'Error calling maintenance view'(m17) TYPE 'A'.
  ENDIF.
ENDFORM.
