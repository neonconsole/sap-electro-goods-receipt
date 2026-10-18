FUNCTION ZKOF6_BUILD_STATUS_RANGE.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_EX_COM) TYPE  ABAP_BOOL
*"     VALUE(IV_EX_PAR) TYPE  ABAP_BOOL
*"     VALUE(IV_EX_NEW) TYPE  ABAP_BOOL
*"  EXPORTING
*"     REFERENCE(ET_RANGE_STATUS) TYPE  ZKOF6_T_RANGE_STATUS
*"----------------------------------------------------------------------

DATA:
    ls_range_status LIKE LINE OF et_range_status.

CLEAR et_range_status.

  ls_range_status-sign = 'E'.
  ls_range_status-option = 'EQ'.

  IF iv_ex_com = abap_true.
    ls_range_status-low = 'COMPLETED'.
    APPEND ls_range_status TO et_range_status.
  ENDIF.

  IF iv_ex_par = abap_true.
    ls_range_status-low = 'PARTIAL'.
    APPEND ls_range_status TO et_range_status.
  ENDIF.

  IF iv_ex_new = abap_true.
    ls_range_status-low = 'NEW'.
    APPEND ls_range_status TO et_range_status.
  ENDIF.

ENDFUNCTION.
