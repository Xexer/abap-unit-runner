CLASS zcl_aur_job_runner DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_apj_rt_run.

    TYPES object_name TYPE c LENGTH 40.
    TYPES objects     TYPE RANGE OF object_name.

    DATA cloud_destination      TYPE string.
    DATA communication_scenario TYPE if_com_management=>ty_cscn_id.
    DATA wait_in_seconds        TYPE i.
    DATA wait_cycles_for_result TYPE i.
    DATA title                  TYPE string.
    DATA scope_own              TYPE abap_boolean.
    DATA scope_foreign          TYPE abap_boolean.
    DATA risklevel_harmless     TYPE abap_boolean.
    DATA risklevel_dangerous    TYPE abap_boolean.
    DATA risklevel_critical     TYPE abap_boolean.
    DATA duration_short         TYPE abap_boolean.
    DATA duration_medium        TYPE abap_boolean.
    DATA duration_long          TYPE abap_boolean.
    DATA packages               TYPE objects.
    DATA classes                TYPE objects.

ENDCLASS.


CLASS zcl_aur_job_runner IMPLEMENTATION.
  METHOD if_apj_rt_run~execute.
    DATA(runner) = zcl_aur_runner=>create( ).

    DATA(objects) = VALUE zif_aur_runner=>aunit_objects( ).

    LOOP AT packages INTO DATA(package).
      INSERT VALUE #( name = package-low
                      type = 'DEVC' ) INTO TABLE objects.
    ENDLOOP.

    LOOP AT classes INTO DATA(class).
      INSERT VALUE #( name = class-low
                      type = 'CLAS' ) INTO TABLE objects.
    ENDLOOP.

    DATA(setting) = VALUE zif_aur_runner=>setting( cloud_destination      = cloud_destination
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
                                                   objects                = objects ).

    DATA(result) = runner->execute( setting ).

    zcl_aur_mail=>create( )->send( result ).
  ENDMETHOD.
ENDCLASS.
