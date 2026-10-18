*----------------------------------------------------------------------*
***INCLUDE ZKOF6_R_MAIN_USER_COMMAND_0I01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.
  CASE gv_0200_ucomm.
    WHEN 'BACK' OR 'CANCEL'.
      PERFORM clear_all_data.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      PERFORM clear_all_data.
      LEAVE PROGRAM.
    WHEN 'APPLYO'.
      PERFORM handle_apply.
    WHEN 'CHECKI'.
      PERFORM handle_checki.
    WHEN 'ADDI'.
      PERFORM handle_addi.
    WHEN 'SUBMIT'.
      PERFORM handle_submit.
  ENDCASE.
  CLEAR gv_0200_ucomm.

ENDMODULE.
