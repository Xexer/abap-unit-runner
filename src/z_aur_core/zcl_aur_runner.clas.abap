CLASS zcl_aur_runner DEFINITION
  PUBLIC FINAL
  CREATE PRIVATE
  GLOBAL FRIENDS zcl_aur_core_factory.

  PUBLIC SECTION.
    INTERFACES zif_aur_runner.

  PRIVATE SECTION.
    CONSTANTS: BEGIN OF header_field,
                 accept   TYPE string VALUE `accept`,
                 location TYPE string VALUE `location`,
               END OF header_field.

    DATA run_setting TYPE zif_aur_runner=>setting.

    "! Set Settings and fill empty default values
    "! @parameter setting | Settings
    METHODS set_settings_and_empty_values
      IMPORTING setting TYPE zif_aur_runner=>setting.

    "! Start des ABAP Unit Run via Interface
    "! @parameter result                      | Path and Run ID
    "! @raising   cx_http_dest_provider_error | Destination Error
    "! @raising   cx_web_http_client_error    | Client Error
    METHODS start_run
      RETURNING VALUE(result) TYPE string
      RAISING   cx_http_dest_provider_error
                cx_web_http_client_error.

    "! Check the Status of the Run
    "! @parameter run_id                      | Path and Run ID
    "! @parameter result                      | Status of the Run
    "! @raising   cx_http_dest_provider_error | Destination Error
    "! @raising   cx_web_http_client_error    | Client Error
    METHODS check_run
      IMPORTING run_id        TYPE string
      RETURNING VALUE(result) TYPE zif_aur_runner=>aunit_run
      RAISING   cx_http_dest_provider_error
                cx_web_http_client_error.

    "! Check the Status of the Run
    "! @parameter run_id                      | Path and Run ID
    "! @parameter result                      | Status of the Run
    "! @raising   cx_http_dest_provider_error | Destination Error
    "! @raising   cx_web_http_client_error    | Client Error
    METHODS run_and_wait_for_result
      IMPORTING run_id        TYPE string
      RETURNING VALUE(result) TYPE zif_aur_runner=>aunit_run
      RAISING   cx_http_dest_provider_error
                cx_web_http_client_error.

    "! Read the final ABAP Unit Results
    "! @parameter run                         | Status of the run
    "! @parameter result                      | Mapped result
    "! @raising   cx_http_dest_provider_error | Destination Error
    "! @raising   cx_web_http_client_error    | Client Error
    METHODS read_results
      IMPORTING !run          TYPE zif_aur_runner=>aunit_run
      RETURNING VALUE(result) TYPE zif_aur_runner=>aunit_result
      RAISING   cx_http_dest_provider_error
                cx_web_http_client_error.

    "! Create client object for HTTP access
    "! @parameter result                      | Client
    "! @raising   cx_http_dest_provider_error | Destination Error
    "! @raising   cx_web_http_client_error    | Client Error
    METHODS get_client
      RETURNING VALUE(result) TYPE REF TO if_web_http_client
      RAISING   cx_http_dest_provider_error
                cx_web_http_client_error.

    "! Create payload to start the AUnit Run
    "! @parameter result | XML Payload
    METHODS get_request_payload
      RETURNING VALUE(result) TYPE string.
ENDCLASS.


CLASS zcl_aur_runner IMPLEMENTATION.
  METHOD check_run.
    DATA(client) = get_client( ).

    DATA(request) = client->get_http_request( ).
    request->set_uri_path( run_id ).
    request->set_header_field( i_name  = header_field-accept
                               i_value = zif_aur_runner=>content_type-check ).

    DATA(response) = client->execute( i_method = if_web_http_client=>get ).

    IF response->get_status( )-code = 200.
      DATA(parser) = zcl_aur_core_factory=>create_parser( ).
      RETURN parser->parse_aunit_run( response->get_text( ) ).
    ENDIF.
  ENDMETHOD.


  METHOD get_client.
    IF run_setting-cloud_destination IS NOT INITIAL.
      DATA(destination) = cl_http_destination_provider=>create_by_cloud_destination(
          i_name       = run_setting-cloud_destination
          i_authn_mode = if_a4c_cp_service=>service_specific ).

    ELSEIF run_setting-communication_scenario IS NOT INITIAL.
      destination = cl_http_destination_provider=>create_by_comm_arrangement( run_setting-communication_scenario ).

    ELSE.
      RAISE EXCEPTION NEW cx_http_dest_provider_error( ).

    ENDIF.

    RETURN cl_web_http_client_manager=>create_by_http_destination( destination ).
  ENDMETHOD.


  METHOD get_request_payload.
    DATA(payload) = zcl_aur_core_factory=>create_payload( ).
    RETURN payload->get_xml_payload( run_setting ).
  ENDMETHOD.


  METHOD read_results.
    DATA(client) = get_client( ).

    DATA(request) = client->get_http_request( ).
    request->set_uri_path( run-result_link ).
    request->set_header_field( i_name  = header_field-accept
                               i_value = zif_aur_runner=>content_type-result ).

    DATA(response) = client->execute( i_method = if_web_http_client=>get ).

    IF response->get_status( )-code = 200.
      DATA(parser) = zcl_aur_core_factory=>create_parser( ).
      RETURN parser->parse_aunit_result( response->get_text( ) ).
    ENDIF.
  ENDMETHOD.


  METHOD run_and_wait_for_result.
    DO.
      DATA(run_index) = sy-index.

      result = check_run( run_id ).
      IF result-progress_status = zif_aur_runner=>run_status-finished.
        EXIT.
      ENDIF.

      IF run_index >= run_setting-wait_cycles_for_result.
        EXIT.
      ELSE.
        WAIT UP TO run_setting-wait_in_seconds SECONDS.
      ENDIF.
    ENDDO.
  ENDMETHOD.


  METHOD set_settings_and_empty_values.
    run_setting = setting.

    IF run_setting-wait_in_seconds IS INITIAL.
      run_setting-wait_in_seconds = 1.
    ENDIF.

    IF run_setting-wait_cycles_for_result IS INITIAL.
      run_setting-wait_cycles_for_result = 60.
    ENDIF.
  ENDMETHOD.


  METHOD start_run.
    DATA(client) = get_client( ).

    DATA(request) = client->get_http_request( ).
    request->set_uri_path( zif_aur_runner=>endpoints-runs ).
    request->set_content_type( zif_aur_runner=>content_type-start ).
    request->set_text( get_request_payload( ) ).

    client->set_csrf_token( ).

    DATA(response) = client->execute( i_method = if_web_http_client=>post ).

    IF response->get_status( )-code = 201.
      RETURN response->get_header_field( header_field-location ).
    ENDIF.
  ENDMETHOD.


  METHOD zif_aur_runner~execute.
    set_settings_and_empty_values( setting ).

    TRY.
        DATA(run_id) = start_run( ).
        DATA(status) = run_and_wait_for_result( run_id ).

        result-aunit_result = read_results( status ).

        IF result-aunit_result-tests = 0.
          result-success = abap_false.
        ELSE.
          result-success = abap_true.
        ENDIF.

      CATCH cx_root INTO DATA(error).
        result-error_message = error->get_text( ).
        result-success       = abap_false.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
