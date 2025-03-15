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
    DATA mail_details              TYPE abap_boolean.

  PRIVATE SECTION.
    "! Collect setting structure from attributes
    "! @parameter result | Setting
    METHODS create_setting
      RETURNING VALUE(result) TYPE zif_aur_runner=>setting.
ENDCLASS.


CLASS zcl_aur_job_runner IMPLEMENTATION.
  METHOD create_setting.
    DATA(mapped_packages) = VALUE zif_aur_runner=>aunit_objects( FOR package IN packages
                                                                 ( package-low ) ).

    DATA(mapped_classes) = VALUE zif_aur_runner=>aunit_objects( FOR class IN classes
                                                                ( class-low ) ).

    DATA(receiver) = VALUE zif_aur_runner=>mail_receivers( FOR receiver_range IN me->receiver
                                                           ( receiver_range-low ) ).

    RETURN VALUE zif_aur_runner=>setting( cloud_destination         = cloud_destination
                                          communication_scenario    = communication_scenario
                                          wait_in_seconds           = wait_in_seconds
                                          wait_cycles_for_result    = wait_cycles_for_result
                                          title                     = title
                                          scope_own                 = scope_own
                                          scope_foreign             = scope_foreign
                                          risklevel_harmless        = risklevel_harmless
                                          risklevel_dangerous       = risklevel_dangerous
                                          risklevel_critical        = risklevel_critical
                                          duration_short            = duration_short
                                          duration_medium           = duration_medium
                                          duration_long             = duration_long
                                          packages                  = mapped_packages
                                          classes                   = mapped_classes
                                          mail_sender               = sender
                                          mail_receiver             = receiver
                                          mail_send_only_with_error = mail_send_only_with_error
                                          mail_details              = mail_details ).
  ENDMETHOD.


  METHOD if_apj_rt_run~execute.
    DATA(setting) = create_setting( ).

    DATA(runner) = zcl_aur_core_factory=>create_runner( ).
    DATA(result) = runner->execute( setting ).

    IF send_mail = abap_true.
      zcl_aur_mail_factory=>create( )->send( setting    = setting
                                             run_result = result ).
    ELSE.
      zcl_aur_job_factory=>create_job_log( )->create_and_attach_log( setting    = setting
                                                                     run_result = result ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
