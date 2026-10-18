*----------------------------------------------------------------------*
***INCLUDE ZKOF6_R_MAIN_F4_PRODUCT_NAMI01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  F4_PRODUCT_NAME  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_product_name INPUT.

  TYPES:
    BEGIN OF ty_f4_product,
      product_id   TYPE zkof6_product_id,
      product_name TYPE zkof6_product_name,
    END OF ty_f4_product.

  DATA:
    lt_f4_list TYPE STANDARD TABLE OF ty_f4_product,
    lt_return  TYPE STANDARD TABLE OF ddshretval,
    lv_dynnr LIKE sy-dynnr.

  SELECT p~product_id, pt~product_name
    FROM zkof6_d_order_i AS oi
    INNER JOIN zkof6_d_product AS p
    ON oi~product_id = p~product_id
    INNER JOIN zkof6_d_prod_t AS pt
    ON p~product_id = pt~product_id
    WHERE oi~order_id = @zkof6_s_order-order_id AND pt~langu = @sy-langu
    INTO CORRESPONDING FIELDS OF TABLE @lt_f4_list.

  lv_dynnr = sy-dynnr.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'product_name'
      dynpprog        = sy-repid
      dynpnr          = lv_dynnr
      dynprofield     = 'ZKOF6_S_PRODUCT-PRODUCT_NAME'
      value_org       = 'S'
    TABLES
      value_tab       = lt_f4_list
      return_tab      = lt_return
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc = 1 OR sy-subrc = 3.
    MESSAGE 'An error occured during fetching help list.'(m18) TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.

  IF sy-subrc = 2.
    MESSAGE 'There are no products assigned to this order.'(m19) TYPE 'S' DISPLAY LIKE 'W'.
  ENDIF.


ENDMODULE.
