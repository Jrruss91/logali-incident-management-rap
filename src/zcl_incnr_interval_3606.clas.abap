CLASS zcl_incnr_interval_3606 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_incnr_interval_3606 IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

    DATA: lt_intervals TYPE cl_numberrange_intervals=>nr_interval.

    lt_intervals = VALUE #( ( nrrangenr  = '01'
                              fromnumber = '00000001'
                              tonumber   = '99999999'
                              procind    = 'I'  ) ).

    TRY.
        cl_numberrange_intervals=>create(
          EXPORTING
            interval  = lt_intervals
            object    = 'ZINCID3606'
            subobject = space
*        option    =
          IMPORTING
            error     = DATA(lv_error)
            error_inf = DATA(ls_error)
            error_iv  = DATA(lt_error)
            warning   = DATA(lv_warning)
        ).

        IF lv_error IS INITIAL.
          out->write( 'Interval 01 created successfully' ).
        ELSE.
          out->write(
           |Error creating interval: { ls_error-msgnr }|
         ).
        ENDIF.

      CATCH cx_nr_object_not_found INTO DATA(lx_nr_object_not_found).

        out->write( lx_nr_object_not_found->get_text( ) ).

      CATCH cx_number_ranges INTO DATA(lx_number_ranges).

        out->write( lx_number_ranges->get_text( ) ).

    ENDTRY.

  ENDMETHOD.

ENDCLASS.
