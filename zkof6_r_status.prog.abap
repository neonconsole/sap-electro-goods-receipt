*&---------------------------------------------------------------------*
*& Report ZKOF6_R_STATUS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zkof6_r_status.

TABLES:
  sscrfields.

TYPES:
  BEGIN OF ty_order_display,
    order_id   TYPE zkof6_d_order_h-order_id,
    name       TYPE zkof6_d_manufact-name,
    order_date TYPE zkof6_d_order_h-order_date,
    status     TYPE zkof6_d_order_h-status,
    created_by TYPE zkof6_d_order_h-created_by,
  END OF ty_order_display.

DATA:
  gs_order_h       TYPE zkof6_d_order_h,
  gt_order_display TYPE TABLE OF ty_order_display.

SELECTION-SCREEN PUSHBUTTON 1(20) TEXT-T03 USER-COMMAND back VISIBLE LENGTH 20.
SELECTION-SCREEN SKIP.
SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-t01.

  SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE TEXT-t02.
    PARAMETERS:
      p_ex_com AS CHECKBOX DEFAULT ' ' USER-COMMAND exclude,
      p_ex_par AS CHECKBOX DEFAULT ' ' USER-COMMAND exclude,
      p_ex_new AS CHECKBOX DEFAULT ' ' USER-COMMAND exclude.
  SELECTION-SCREEN END OF BLOCK b02.
  PARAMETERS:
  p_addflt AS CHECKBOX DEFAULT ' ' USER-COMMAND toggle_filters.

  SELECT-OPTIONS:
  s_ord_id FOR gs_order_h-order_id MODIF ID gr1,
  s_user FOR gs_order_h-created_by MODIF ID gr1,
  s_date FOR gs_order_h-order_date MODIF ID gr1.


SELECTION-SCREEN END OF BLOCK b01.

AT SELECTION-SCREEN.
  IF p_ex_com = abap_true AND p_ex_par = abap_true AND p_ex_new = abap_true.
    MESSAGE 'Cannot exclude every order status simultaneously.'(m01) TYPE 'E'.
  ENDIF.

  IF sscrfields-ucomm = 'BACK'.
    LEAVE TO TRANSACTION 'ZKOF6_ORDER_RECEIVE'.
  ENDIF.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 = 'GR1' AND p_addflt = abap_true.
      screen-active = '1'.
      MODIFY SCREEN.
    ELSEIF screen-group1 = 'GR1' AND p_addflt = abap_false.
      screen-active = '0'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

START-OF-SELECTION.

  PERFORM select_data.

  PERFORM display_data.

FORM select_data.

   DATA:
    lt_range_status TYPE zkof6_t_range_status.

  CALL FUNCTION 'ZKOF6_BUILD_STATUS_RANGE'
    EXPORTING
      iv_ex_com             = p_ex_com
      iv_ex_par             = p_ex_par
      iv_ex_new             = p_ex_new
   IMPORTING
     ET_RANGE_STATUS       = lt_range_status.

  SELECT oh~order_id, m~name,oh~order_date, oh~status, oh~created_by
    FROM zkof6_d_order_h AS oh
    INNER JOIN zkof6_d_manufact AS m
      ON oh~manufacturer_id = m~manufacturer_id
    WHERE
    oh~order_id IN @s_ord_id
    AND oh~created_by IN @s_user
    AND oh~order_date IN @s_date
    AND oh~status IN @lt_range_status
    INTO TABLE @gt_order_display.

  IF sy-subrc <> 0.
    MESSAGE 'No data fetched.'(m02) TYPE 'S' DISPLAY LIKE 'W'.
    STOP.
  ENDIF.
ENDFORM.

FORM display_data.


  TRY.
      cl_salv_table=>factory(
        IMPORTING r_salv_table = DATA(lo_salv)
        CHANGING t_table = gt_order_display ).

      lo_salv->get_functions( )->set_all( abap_true ).
      lo_salv->display( ).

    CATCH cx_salv_msg INTO DATA(lx_salv).
      DATA(lv_error_message) = lx_salv->get_text( ).
      MESSAGE lv_error_message TYPE 'S' DISPLAY LIKE 'E'.
  ENDTRY.
ENDFORM.
