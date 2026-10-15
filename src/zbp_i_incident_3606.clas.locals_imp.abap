CLASS lhc_Incident DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    CONSTANTS:
      BEGIN OF incident_status,
        open        TYPE c LENGTH 2 VALUE 'OP',
        in_progress TYPE c LENGTH 2 VALUE 'IP',
        pending     TYPE c LENGTH 2 VALUE 'PE',
        completed   TYPE c LENGTH 2 VALUE 'CO',
        closed      TYPE c LENGTH 2 VALUE 'CL',
        canceled    TYPE c LENGTH 2 VALUE 'CN',
      END OF incident_status.

    CONSTANTS:
      BEGIN OF incident_priority,
        high   TYPE c LENGTH 1 VALUE 'H',
        medium TYPE c LENGTH 1 VALUE 'M',
        low    TYPE c LENGTH 1 VALUE 'L',
      END OF incident_priority.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR Incident RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR Incident RESULT result.

    METHODS setInitialValues FOR DETERMINE ON MODIFY
       keys FOR Incident~setInitialValues.

    METHODS createInitialHistory FOR DETERMINE ON SAVE
       keys FOR Incident~createInitialHistory.

    METHODS validateInitialHistory FOR VALIDATE ON SAVE
       keys FOR Incident~validateInitialHistory.
    METHODS validateIncidentId FOR VALIDATE ON SAVE
       keys FOR Incident~validateIncidentId.
    METHODS validateDates FOR VALIDATE ON SAVE
       keys FOR Incident~validateDates.
    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR Incident RESULT result.

    METHODS changeStatus FOR MODIFY
       keys FOR ACTION Incident~changeStatus RESULT result.

ENDCLASS.

CLASS lhc_Incident IMPLEMENTATION.

  METHOD get_instance_authorizations.

    result = VALUE #( FOR key IN keys ( %tky = key-%tky
                                        %update = if_abap_behv=>auth-allowed
                                        %delete = if_abap_behv=>auth-allowed
                                        %action-Edit = if_abap_behv=>auth-allowed ) ).

  ENDMETHOD.

  METHOD get_global_authorizations.

    IF requested_authorizations-%create = if_abap_behv=>mk-on.

      result-%create = if_abap_behv=>auth-allowed.

    ENDIF.


  ENDMETHOD.

  METHOD setInitialValues.

    DATA lt_updates TYPE TABLE FOR UPDATE zi_incident_3606.

    READ ENTITIES OF zi_incident_3606
      IN LOCAL MODE
      ENTITY Incident
      FIELDS ( IncidentId CreateDate Status )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_incidents).

    DELETE lt_incidents WHERE IncidentId IS NOT INITIAL
                          AND Status IS NOT INITIAL
                          AND CreateDate IS NOT INITIAL.

    CHECK lt_incidents IS NOT INITIAL.

    LOOP AT lt_incidents ASSIGNING FIELD-SYMBOL(<fs_incident>).

      " Asignamos el valor al campo status
      IF <fs_incident>-Status IS INITIAL.
        <fs_incident>-Status = incident_status-open.
      ENDIF.

      " Asignamos el valor al campo created date
      IF <fs_incident>-CreateDate IS INITIAL.
        <fs_incident>-CreateDate = cl_abap_context_info=>get_system_date( ).
      ENDIF.

      IF <fs_incident>-IncidentId IS INITIAL.
        " Procedemos a crear la numeración del campo Incident ID
        DATA(lo_number_range) = cl_numberrange_buffer=>get_instance( ).
        TRY.

            lo_number_range->if_numberrange_buffer~number_get_main_memory(
              EXPORTING
                iv_object            = 'ZINCID3606'
                iv_interval          = '01'
                iv_quantity          = '1'
              IMPORTING
                ev_number            = DATA(lv_number)
                ev_returncode        = DATA(lt_returncode)
                ev_returned_quantity = DATA(lv_quantity)
            ).

            IF lv_number IS INITIAL OR lv_quantity <> 1.
              APPEND VALUE #(
               %tky = <fs_incident>-%tky
               %element-IncidentId = if_abap_behv=>mk-on
               %msg = new_message(
               id   = 'ZMC_INCIDENT_3606'
               number = '003'
               severity = if_abap_behv_message=>severity-error
             )
            ) TO reported-incident.

              CONTINUE.

            ENDIF.

            <fs_incident>-IncidentId = lv_number.

          CATCH cx_number_ranges INTO DATA(lx_error).

            APPEND VALUE #(
             %tky = <fs_incident>-%tky
             %element-IncidentId = if_abap_behv=>mk-on
             %msg = new_message_with_text(
             text = lx_error->get_text( )
             severity = if_abap_behv_message=>severity-error
             )
           ) TO reported-incident.

            CONTINUE.
        ENDTRY.

      ENDIF.
      APPEND VALUE #( %tky       = <fs_incident>-%tky
                      IncidentId = <fs_incident>-IncidentId
                      CreateDate = <fs_incident>-CreateDate
                      Status     = <fs_incident>-Status ) TO lt_updates.

    ENDLOOP.

    IF lt_updates IS NOT INITIAL.
      MODIFY ENTITIES OF zi_incident_3606 IN LOCAL
        MODE ENTITY Incident
        UPDATE
        FIELDS ( IncidentId CreateDate Status )
        WITH lt_updates
        REPORTED DATA(lt_reported).

      reported = CORRESPONDING #( DEEP BASE ( reported ) lt_reported ).

    ENDIF.

  ENDMETHOD.

  METHOD createInitialHistory.

    DATA lt_create_history
    TYPE TABLE FOR CREATE zi_incident_3606\_History.

    DATA lv_cid TYPE i.

    READ ENTITIES OF zi_incident_3606 IN LOCAL
     MODE ENTITY Incident
     FIELDS ( IncUuid IncidentId Status )
     WITH CORRESPONDING #( keys )
     RESULT DATA(lt_incidents)
     REPORTED DATA(lt_reported).

    READ ENTITIES OF zi_incident_3606 IN LOCAL
        MODE ENTITY Incident BY \_History
        FIELDS ( HisUuid IncUuid )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_histories).

    LOOP AT lt_incidents ASSIGNING FIELD-SYMBOL(<fs_incident>).

      IF line_exists( lt_histories[ IncUuid = <fs_incident>-IncUuid ] ).
        CONTINUE.
      ENDIF.

      IF <fs_incident>-Status <> incident_status-open.
        CONTINUE.
      ENDIF.

      lv_cid += 1.

      APPEND VALUE #( %tky = <fs_incident>-%tky
                      %target = VALUE #( ( %cid      = |HIST{ lv_cid }|
                                           HisId     = '00000001'
                                           NewStatus = incident_status-open
                                           text      = 'First Incident' ) ) ) TO lt_create_history.

    ENDLOOP.

    IF lt_create_history IS NOT INITIAL.
      MODIFY ENTITIES OF zi_incident_3606 IN LOCAL MODE
       ENTITY Incident
       CREATE BY \_History
       FIELDS ( HisId NewStatus Text )
       WITH lt_create_history
       MAPPED DATA(lt_mapped)
       FAILED DATA(lt_failed)
       REPORTED DATA(lt_reported_history).

      reported = CORRESPONDING #( DEEP BASE ( reported ) lt_reported_history ).

      IF lt_failed IS NOT INITIAL.
        APPEND VALUE #( %global = if_abap_behv=>mk-on
                        %msg    = new_message(
                        id      = 'ZMC_INCIDENT_3606'
                        number  = '001'
                        severity = if_abap_behv_message=>severity-error ) ) TO reported-incident.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD validateInitialHistory.

    " Leemos los incidentes
    READ ENTITIES OF zi_incident_3606 IN LOCAL MODE
      ENTITY Incident
      FIELDS ( IncUuid )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_incidents).

    " Leemos los registros relacionados de historial
    READ ENTITIES OF zi_incident_3606 IN LOCAL MODE
      ENTITY Incident BY \_History
      FIELDS ( IncUuid HisId NewStatus Text )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_histories).

    LOOP AT lt_incidents ASSIGNING FIELD-SYMBOL(<fs_incident>).

      " Limpiar mensajes
      APPEND VALUE #( %tky = <fs_incident>-%tky
                      %state_area = 'INITIAL_HISTORY' ) TO reported-incident.

      " Verificar que existe el historial inicial
      IF line_exists(
        lt_histories[
          IncUuid   = <fs_incident>-IncUuid
          HisId     = '00000001'
          NewStatus = incident_status-open
          Text      = 'First Incident'
        ]
      ).
        CONTINUE.
      ENDIF.

      " Impedir el guardado del incidente
      APPEND VALUE #(
        %tky = <fs_incident>-%tky
      ) TO failed-incident.

      " Informar el motivo del error
      APPEND VALUE #(
        %tky        = <fs_incident>-%tky
        %state_area = 'INITIAL_HISTORY'
        %msg        = new_message(
          id       = 'ZMC_INCIDENT_3606'
          number   = '002'
          severity = if_abap_behv_message=>severity-error
        )
      ) TO reported-incident.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateIncidentId.

    READ ENTITIES OF zi_incident_3606 IN LOCAL MODE
      ENTITY Incident
      FIELDS ( IncidentId )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_incidents).

    LOOP AT lt_incidents ASSIGNING FIELD-SYMBOL(<fs_incident>).

      " Limpiar mensajes anteriores
      APPEND VALUE #(
        %tky        = <fs_incident>-%tky
        %state_area = 'INCIDENT_ID'
      ) TO reported-incident.

      " Comprobar identificador
      IF <fs_incident>-IncidentId IS NOT INITIAL.
        CONTINUE.
      ENDIF.

      " Impedir el guardado
      APPEND VALUE #(
        %tky = <fs_incident>-%tky
      ) TO failed-incident.

      " Comunicar el error
      APPEND VALUE #(
        %tky                = <fs_incident>-%tky
        %state_area         = 'INCIDENT_ID'
        %element-IncidentId = if_abap_behv=>mk-on
        %msg = new_message(
          id       = 'ZMC_INCIDENT_3606'
          number   = '003'
          severity = if_abap_behv_message=>severity-error
        )
      ) TO reported-incident.

    ENDLOOP.
  ENDMETHOD.

  METHOD validateDates.

    DATA: lv_invalid TYPE abap_bool VALUE IS INITIAL.

    READ ENTITIES OF zi_incident_3606 IN LOCAL MODE
       ENTITY Incident
       FIELDS ( CreateDate ChangedDate )
       WITH CORRESPONDING #( keys )
       RESULT DATA(lt_incidents).

    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).

    LOOP AT lt_incidents ASSIGNING FIELD-SYMBOL(<fs_incident>).

      lv_invalid = abap_false.

      APPEND VALUE #( %tky        = <fs_incident>-%tky
                      %state_area = 'CREATED_DATE' ) TO reported-incident.

      IF <fs_incident>-CreateDate > lv_today.

        " Impedir el guardado
        lv_invalid = abap_true.

        " Comunicar el error
        APPEND VALUE #(
          %tky                = <fs_incident>-%tky
          %state_area         = 'CREATED_DATE'
          %element-createDate = if_abap_behv=>mk-on
          %msg = new_message(
            id       = 'ZMC_INCIDENT_3606'
            number   = '004'
            severity = if_abap_behv_message=>severity-error
          )
        ) TO reported-incident.

      ENDIF.

      IF <fs_incident>-CreateDate IS INITIAL.

        " Impedir el guardado
        lv_invalid = abap_true.

        " Comunicar el error
        APPEND VALUE #(
          %tky = <fs_incident>-%tky
          %state_area = 'CREATED_DATE'
          %element-CreateDate = if_abap_behv=>mk-on
          %msg = new_message(
            id       = 'ZMC_INCIDENT_3606'
            number   = '006'
            severity = if_abap_behv_message=>severity-error
          )
        ) TO reported-incident.
      ENDIF.


      APPEND VALUE #(
       %tky        = <fs_incident>-%tky
       %state_area = 'CHANGED_DATE'
     ) TO reported-incident.

      IF <fs_incident>-ChangedDate IS NOT INITIAL
      AND <fs_incident>-CreateDate IS NOT INITIAL
      AND <fs_incident>-ChangedDate < <fs_incident>-CreateDate.

        " Impedir el guardado
        lv_invalid = abap_true.

        " Comunicar el error
        APPEND VALUE #(
          %tky                 = <fs_incident>-%tky
          %state_area          = 'CHANGED_DATE'
          %element-changeddate = if_abap_behv=>mk-on
          %msg = new_message(
            id       = 'ZMC_INCIDENT_3606'
            number   = '005'
            severity = if_abap_behv_message=>severity-error
          )
        ) TO reported-incident.

      ENDIF.

      IF lv_invalid EQ abap_true.

        APPEND VALUE #( %tky = <fs_incident>-%tky ) TO failed-incident.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF zi_incident_3606 IN LOCAL
       MODE ENTITY Incident
       FIELDS ( Status )
       WITH CORRESPONDING #( keys )
       RESULT DATA(lt_incidents)
       FAILED failed.

    result = VALUE #( FOR ls_incident IN lt_incidents
                    ( %tky = ls_incident-%tky
                      %features-%action-changeStatus = COND #( WHEN ls_incident-Status = incident_status-completed
                                                                 OR ls_incident-Status = incident_status-closed
                                                                 OR ls_incident-Status = incident_status-canceled
                                                               THEN if_abap_behv=>fc-o-disabled
                                                               ELSE if_abap_behv=>fc-o-enabled ) ) ).

  ENDMETHOD.

  METHOD changeStatus.

    DATA lt_status_updates
         TYPE TABLE FOR UPDATE zi_incident_3606.

    DATA lt_create_history
         TYPE TABLE FOR CREATE zi_incident_3606\_History.

    DATA: lv_invalid TYPE abap_bool.

    READ ENTITIES OF zi_incident_3606 IN LOCAL
      MODE ENTITY Incident
      FIELDS ( IncUuid Status )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_incidents).

    READ ENTITIES OF zi_incident_3606 IN LOCAL MODE
     ENTITY Incident BY \_History
     FIELDS ( IncUuid HisId )
     WITH CORRESPONDING #( keys )
     RESULT DATA(lt_histories).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_key>).

      lv_invalid = abap_false.

      APPEND VALUE #(
        %tky        = <fs_key>-%tky
        %state_area = 'CHANGE_STATUS'
      ) TO reported-incident.

      " Obtener el incidente correspondiente
      READ TABLE lt_incidents
        ASSIGNING FIELD-SYMBOL(<fs_incident>)
        WITH KEY id COMPONENTS %tky = <fs_key>-%tky.

      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      " Recuperar los parámetros de la acción
      DATA(lv_new_status) = <fs_key>-%param-NewStatus.
      DATA(lv_observation) = <fs_key>-%param-Observation.

      " Estado actual del incidente
      DATA(lv_current_status) = <fs_incident>-Status.

      IF lv_current_status = incident_status-completed
      OR lv_current_status = incident_status-closed
      OR lv_current_status = incident_status-canceled.

        " FAILED + REPORTED
        lv_invalid = abap_true.
*        APPEND VALUE #( %tky = <fs_key>-%tky ) TO failed-incident.

        " Comunicar el error
        APPEND VALUE #(
          %tky                 = <fs_incident>-%tky
          %state_area          = 'CHANGE_STATUS'
          %msg = new_message(
            id       = 'ZMC_INCIDENT_3606'
            number   = '007'
            severity = if_abap_behv_message=>severity-error
          )
        ) TO reported-incident.

*        CONTINUE.

      ENDIF.

      IF lv_current_status = incident_status-pending
     AND ( lv_new_status = incident_status-completed
      OR lv_new_status = incident_status-closed ).


        " FAILED + REPORTED
        lv_invalid = abap_true.
*        APPEND VALUE #(
*          %tky = <fs_key>-%tky
*        ) TO failed-incident.

        APPEND VALUE #(
          %tky        = <fs_key>-%tky
          %state_area = 'CHANGE_STATUS'
          %msg = new_message(
            id       = 'ZMC_INCIDENT_3606'
            number   = '008'
            severity = if_abap_behv_message=>severity-error
          )
        ) TO reported-incident.

*        CONTINUE.

      ENDIF.

      CASE lv_new_status.

        WHEN incident_status-open
          OR incident_status-in_progress
          OR incident_status-pending
          OR incident_status-completed
          OR incident_status-closed
          OR incident_status-canceled.

          " Estado válido, continuar procesamiento

        WHEN OTHERS.

          lv_invalid = abap_true.

          APPEND VALUE #(
            %tky        = <fs_key>-%tky
            %state_area = 'CHANGE_STATUS'
            %msg = new_message(
              id       = 'ZMC_INCIDENT_3606'
              number   = '009'
              severity = if_abap_behv_message=>severity-error
            )
          ) TO reported-incident.

      ENDCASE.

      IF lv_new_status = lv_current_status.

        lv_invalid = abap_true.

        APPEND VALUE #(
          %tky        = <fs_key>-%tky
          %state_area = 'CHANGE_STATUS'
          %msg = new_message(
            id       = 'ZMC_INCIDENT_3606'
            number   = '010'
            severity = if_abap_behv_message=>severity-error
          )
        ) TO reported-incident.

      ENDIF.

      IF lv_invalid EQ abap_true.
        APPEND VALUE #(
          %tky = <fs_key>-%tky
        ) TO failed-incident.

        CONTINUE.
      ENDIF.

      " Preparar actualización del incidente
      APPEND VALUE #(
        %tky        = <fs_key>-%tky
        Status      = lv_new_status
        ChangedDate = cl_abap_context_info=>get_system_date( )
      ) TO lt_status_updates.

    ENDLOOP.

    IF lt_status_updates IS NOT INITIAL.

      MODIFY ENTITIES OF zi_incident_3606 IN LOCAL MODE
        ENTITY Incident
        UPDATE FIELDS ( Status ChangedDate )
        WITH lt_status_updates
        FAILED DATA(lt_update_failed)
        REPORTED DATA(lt_update_reported).

      failed = CORRESPONDING #(
        DEEP BASE ( failed ) lt_update_failed
      ).

      reported = CORRESPONDING #(
        DEEP BASE ( reported ) lt_update_reported
      ).

    ENDIF.

  ENDMETHOD.

ENDCLASS.

