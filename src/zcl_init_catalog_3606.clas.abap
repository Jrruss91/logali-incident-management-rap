
CLASS zcl_init_catalog_3606 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

ENDCLASS.


CLASS zcl_init_catalog_3606 IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    " Catalogo de estados
    DATA lt_status TYPE STANDARD TABLE OF
      zdt_status_3606 WITH EMPTY KEY.

    lt_status = VALUE #(
      ( status_code = 'OP'
        status_description = 'Open' )

      ( status_code = 'IP'
        status_description = 'In Progress' )

      ( status_code = 'PE'
        status_description = 'Pending' )

      ( status_code = 'CO'
        status_description = 'Completed' )

      ( status_code = 'CL'
        status_description = 'Closed' )

      ( status_code = 'CN'
        status_description = 'Canceled' )
    ).

    " Insertar o actualizar estados
    MODIFY zdt_status_3606
      FROM TABLE @lt_status.

*    " Insertar solo registros nuevos
*    INSERT zdt_status_3606
*      FROM TABLE @lt_status
*      ACCEPTING DUPLICATE KEYS.

    DATA(lv_status_count) = sy-dbcnt.


    " Catalogo de prioridades
    DATA lt_priority TYPE STANDARD TABLE OF
      zdt_priorit_3606 WITH EMPTY KEY.

    lt_priority = VALUE #(
      ( priority_code = 'H'
        priority_description = 'High' )

      ( priority_code = 'M'
        priority_description = 'Medium' )

      ( priority_code = 'L'
        priority_description = 'Low' )
    ).

    " Insertar o actualizar prioridades
    MODIFY zdt_priorit_3606
      FROM TABLE @lt_priority.

*    INSERT zdt_priorit_3606
*      FROM TABLE @lt_priority
*      ACCEPTING DUPLICATE KEYS.

    DATA(lv_priority_count) = sy-dbcnt.


    " Resultado de la carga
    out->write(
      |Estados insertados: { lv_status_count }|
    ).

    out->write(
      |Prioridades insertadas: { lv_priority_count }|
    ).

  ENDMETHOD.

ENDCLASS.

