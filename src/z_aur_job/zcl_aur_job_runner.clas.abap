CLASS zcl_aur_job_runner DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_apj_rt_run.

    TYPES objects           TYPE RANGE OF zif_aur_runner=>aunit_object.
    TYPES receiver_as_range TYPE RANGE OF cl_bcs_mail_message=>ty_address.

    DATA cloud_destination         TYPE string.
    DATA communication_scenario    TYPE if_com_management=>ty_cscn_id.
    DATA wait_in_seconds           TYPE i.
    DATA wait_cycles_for_result    TYPE i.
    DATA title                     TYPE string.
    DATA scope_own                 TYPE abap_boolean.
    DATA scope_foreign             TYPE abap_boolean.
    DATA risklevel_harmless        TYPE abap_boolean.
    DATA risklevel_dangerous       TYPE abap_boolean.
    DATA risklevel_critical        TYPE abap_boolean.
    DATA duration_short            TYPE abap_boolean.
    DATA duration_medium           TYPE abap_boolean.
    DATA duration_long             TYPE abap_boolean.
    DATA packages                  TYPE objects.
    DATA classes                   TYPE objects.
    DATA sender                    TYPE cl_bcs_mail_message=>ty_address.
    DATA receiver                  TYPE receiver_as_range.
    DATA mail_send_only_with_error TYPE abap_boolean.
    DATA send_mail                 TYPE abap_boolean.

  PRIVATE SECTION.
    "! Collect setting structure from attributes
    "! @parameter result | Setting
    METHODS create_setting
      RETURNING VALUE(result) TYPE zif_aur_runner=>setting.

    "! Output the protocol into application job
    "! @parameter setting    | Settings
    "! @parameter run_result | Run Settings
    METHODS output_to_log
      IMPORTING setting    TYPE zif_aur_runner=>setting
                run_result TYPE zif_aur_runner=>run_result.
ENDCLASS.



CLASS ZCL_AUR_JOB_RUNNER IMPLEMENTATION.


  METHOD create_setting.
    DATA mapped_packages TYPE zif_aur_runner=>aunit_objects.
    DATA mapped_classes  TYPE zif_aur_runner=>aunit_objects.
    DATA receiver        TYPE zif_aur_runner=>mail_receivers.

    LOOP AT packages INTO DATA(package).
      INSERT package-low INTO TABLE mapped_packages.
    ENDLOOP.

    LOOP AT classes INTO DATA(class).
      INSERT class-low INTO TABLE mapped_classes.
    ENDLOOP.

    LOOP AT me->receiver INTO DATA(receiver_range).
      INSERT receiver_range-low INTO TABLE receiver.
    ENDLOOP.

    RETURN VALUE zif_aur_runner=>setting( cloud_destination      = cloud_destination
                                          communication_scenario = communication_scenario
                                          wait_in_seconds        = wait_in_seconds
                                          wait_cycles_for_result = wait_cycles_for_result
                                          title                  = title
                                          scope_own              = scope_own
                                          scope_foreign          = scope_foreign
                                          risklevel_harmless     = risklevel_harmless
                                          risklevel_dangerous    = risklevel_dangerous
                                          risklevel_critical     = risklevel_critical
                                          duration_short         = duration_short
                                          duration_medium        = duration_medium
                                          duration_long          = duration_long
                                          packages               = mapped_packages
                                          classes                = mapped_classes
                                          mail_sender            = sender
                                          mail_receiver          = receiver ).
  ENDMETHOD.


  METHOD if_apj_rt_run~execute.
    DATA(setting) = create_setting( ).

    DATA(runner) = zcl_aur_core_factory=>create_runner( ).
    DATA(result) = runner->execute( setting ).

    IF send_mail = abap_true.
      zcl_aur_mail_factory=>create( )->send( setting    = setting
                                             run_result = result ).
    ELSE.
      output_to_log( setting    = setting
                     run_result = result ).
    ENDIF.
  ENDMETHOD.


  METHOD output_to_log.
    TRY.
        DATA(lo_log) = cl_bali_log=>create( ).

        lo_log->set_header( cl_bali_header_setter=>create(
                                object      = 'Z_AUR_LOG'
                                subobject   = 'RUN'
                                external_id = CONV #( xco_cp=>uuid( )->as( xco_cp_uuid=>format->c32 )->value ) ) ).

        lo_log->add_item( cl_bali_message_setter=>create( severity   = if_bali_constants=>c_severity_status
                                                          id         = 'Z_AUR'
                                                          number     = '001'
                                                          variable_1 = CONV #( run_result-aunit_result-tests ) ) ).

        IF run_result-aunit_result-failures > 0 OR run_result-aunit_result-asserts > 0.
          lo_log->add_item( cl_bali_message_setter=>create( severity   = if_bali_constants=>c_severity_error
                                                            id         = 'Z_AUR'
                                                            number     = '002'
                                                            variable_1 = CONV #( run_result-aunit_result-tests ) ) ).
        ELSE.
          lo_log->add_item( cl_bali_message_setter=>create( severity   = if_bali_constants=>c_severity_status
                                                            id         = 'Z_AUR'
                                                            number     = '003'
                                                            variable_1 = CONV #( run_result-aunit_result-tests ) ) ).
        ENDIF.

        cl_bali_log_db=>get_instance( )->save_log( log                        = lo_log
                                                   assign_to_current_appl_job = abap_true ).
      CATCH cx_bali_runtime.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
