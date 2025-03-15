CLASS zcl_aur_job_log DEFINITION
  PUBLIC FINAL
  CREATE PRIVATE
  GLOBAL FRIENDS zcl_aur_job_factory.

  PUBLIC SECTION.
    INTERFACES zif_aur_job_log.

  PRIVATE SECTION.
    CONSTANTS appl_log_main TYPE balobj_d  VALUE 'Z_AUR_LOG'.
    CONSTANTS appl_log_sub  TYPE balsubobj VALUE 'RUN'.

    DATA application_log TYPE REF TO if_bali_log.

    "! Add general part for the run
    "! @parameter run_result      | Result of the run
    "! @raising   cx_bali_runtime | Error in Log
    METHODS add_general_part
      IMPORTING run_result TYPE zif_aur_runner=>run_result
      RAISING   cx_bali_runtime.

    "! Add details for class and run
    "! @parameter run_result      | Result of the run
    "! @raising   cx_bali_runtime | Error in Log
    METHODS add_details_part
      IMPORTING run_result TYPE zif_aur_runner=>run_result
      RAISING   cx_bali_runtime.
ENDCLASS.


CLASS zcl_aur_job_log IMPLEMENTATION.
  METHOD zif_aur_job_log~create_and_attach_log.
    TRY.
        application_log = cl_bali_log=>create( ).

        application_log->set_header(
            cl_bali_header_setter=>create(
                object      = appl_log_main
                subobject   = appl_log_sub
                external_id = CONV #( xco_cp=>uuid( )->as( xco_cp_uuid=>format->c32 )->value ) ) ).

        add_general_part( run_result ).
        add_details_part( run_result ).

        cl_bali_log_db=>get_instance( )->save_log( log                        = application_log
                                                   assign_to_current_appl_job = abap_true ).

      CATCH cx_bali_runtime INTO DATA(error_bali).
        RAISE SHORTDUMP error_bali.
    ENDTRY.
  ENDMETHOD.


  METHOD add_general_part.
    application_log->add_item( cl_bali_message_setter=>create( severity   = if_bali_constants=>c_severity_status
                                                               id         = 'Z_AUR'
                                                               number     = '001'
                                                               variable_1 = CONV #( run_result-aunit_result-tests ) ) ).

    IF run_result-aunit_result-failures > 0 OR run_result-aunit_result-asserts > 0.
      application_log->add_item( cl_bali_message_setter=>create(
                                     severity   = if_bali_constants=>c_severity_error
                                     id         = 'Z_AUR'
                                     number     = '002'
                                     variable_1 = CONV #( run_result-aunit_result-tests ) ) ).
    ELSE.
      application_log->add_item( cl_bali_message_setter=>create(
                                     severity   = if_bali_constants=>c_severity_status
                                     id         = 'Z_AUR'
                                     number     = '003'
                                     variable_1 = CONV #( run_result-aunit_result-tests ) ) ).
    ENDIF.
  ENDMETHOD.


  METHOD add_details_part.
    ##TODO
  ENDMETHOD.
ENDCLASS.
