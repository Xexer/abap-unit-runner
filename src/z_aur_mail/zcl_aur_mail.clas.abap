CLASS zcl_aur_mail DEFINITION
  PUBLIC FINAL
  CREATE PRIVATE
  GLOBAL FRIENDS zcl_aur_mail_factory.

  PUBLIC SECTION.
    INTERFACES zif_aur_mail.

  PRIVATE SECTION.
    DATA setting TYPE zif_aur_runner=>setting.

    "! Send the document to the receiver
    "! @parameter document_content | Prepared mail content
    "! @parameter result           | Result for the mail
    METHODS send_final_document
      IMPORTING document_content TYPE string
      RETURNING VALUE(result)    TYPE zif_aur_mail=>mail_result.

    "! Create mail content for result
    "! @parameter run_result | Test Result
    "! @parameter result     | String for Mail
    METHODS create_mail_content
      IMPORTING run_result    TYPE zif_aur_runner=>run_result
      RETURNING VALUE(result) TYPE string.

    "! Generate general part (Header informations)
    "! @parameter run_result | Result of ABAP Unit run
    "! @parameter html       | HTML Document
    METHODS generate_general_part
      IMPORTING run_result TYPE zif_aur_runner=>run_result
                html       TYPE REF TO zif_aur_mail_html.

    "! Get different packages from run
    "! @parameter run_result | Result of ABAP Unit run
    "! @parameter result     | List of packages
    METHODS get_included_packages
      IMPORTING run_result    TYPE zif_aur_runner=>run_result
      RETURNING VALUE(result) TYPE string_table.

    "! Generate the content for the package
    "! @parameter run_result | Result of ABAP Unit run
    "! @parameter package    | Name of the package
    "! @parameter html       | HTML content
    METHODS generate_package
      IMPORTING run_result TYPE zif_aur_runner=>run_result
                !package   TYPE string
                html       TYPE REF TO zif_aur_mail_html.

    "! Extract the name of the global and test class
    "! @parameter name   | Name in pattern "zbs_demo_tests.clas:zcl_bs_demo_roman_numbers---ltc_arabic_to_roman"
    "! @parameter result | Parsed name for output
    METHODS extract_object_name
      IMPORTING !name         TYPE string
      RETURNING VALUE(result) TYPE string.

    METHODS generate_method_details
      IMPORTING html    TYPE REF TO zif_aur_mail_html
                !detail TYPE zif_aur_runner=>aunit_test.

ENDCLASS.


CLASS zcl_aur_mail IMPLEMENTATION.
  METHOD create_mail_content.
    DATA(html) = zcl_aur_mail_factory=>create_html( ).

    generate_general_part( run_result = run_result
                           html       = html ).

    DATA(packages) = get_included_packages( run_result ).
    LOOP AT packages INTO DATA(package).
      html->add_break( ).
      html->add_big_header( |{ TEXT-004 }: { to_upper( package ) }| ).

      generate_package( run_result = run_result
                        package    = package
                        html       = html ).
    ENDLOOP.

    RETURN html->finish_document( ).
  ENDMETHOD.


  METHOD extract_object_name.
    TRY.
        DATA(splitted) = xco_cp=>string( name )->to_upper_case( )->split( `:` )->value.
        DATA(classes) = xco_cp=>string( splitted[ lines( splitted ) ] )->split( `---` )->value.

        IF lines( classes ) = 2.
          RETURN |{ classes[ 1 ] } [{ classes[ 2 ] }]|.
        ELSE.
          RETURN classes[ 1 ].
        ENDIF.

      CATCH cx_root.
        RETURN to_upper( name ).
    ENDTRY.
  ENDMETHOD.


  METHOD generate_general_part.
    DATA(general) = VALUE zif_aur_mail=>general_parts( ( title          = TEXT-005
                                                         system         = TEXT-006
                                                         client         = TEXT-007
                                                         execution_user = TEXT-008
                                                         time           = TEXT-009
                                                         timestamp      = TEXT-010
                                                         failures       = TEXT-011
                                                         errors         = TEXT-012
                                                         skipped        = TEXT-013
                                                         asserts        = TEXT-014
                                                         tests          = TEXT-015 ) ).
    INSERT CORRESPONDING #( run_result-aunit_result ) INTO TABLE general.

    html->add_big_header( TEXT-003 ).
    html->add_table( generic_data = REF #( general )
                     formats      = VALUE #( ( column = 7 negative = abap_true )
                                             ( column = 8 negative = abap_true )
                                             ( column = 10 negative = abap_true )
                                             ( column = 11 positive = abap_true ) ) ).
  ENDMETHOD.


  METHOD generate_package.
    LOOP AT run_result-aunit_result-test_details INTO DATA(detail) WHERE package = package.
      DATA(objects) = VALUE zif_aur_mail=>object_parts( ( tests     = TEXT-015
                                                          failures  = TEXT-011
                                                          errors    = TEXT-012
                                                          skipped   = TEXT-013
                                                          asserts   = TEXT-014
                                                          timestamp = TEXT-010
                                                          time      = TEXT-016 ) ).
      INSERT CORRESPONDING #( detail ) INTO TABLE objects.

      DATA(object_name) = extract_object_name( detail-test_methods[ 1 ]-classname ).

      html->add_medium_header( object_name ).
      html->add_table( generic_data = REF #( objects )
                       formats      = VALUE #( ( column = 1 positive = abap_true )
                                               ( column = 2 negative = abap_true )
                                               ( column = 3 negative = abap_true )
                                               ( column = 5 negative = abap_true ) ) ).

      generate_method_details( html   = html
                               detail = detail ).
    ENDLOOP.
  ENDMETHOD.


  METHOD generate_method_details.
    IF setting-mail_details = abap_false.
      RETURN.
    ENDIF.

    DATA(methods) = VALUE zif_aur_mail=>method_parts(
        ( name = TEXT-017 time = TEXT-016 asserts = TEXT-014 message = 'Message'(018) ) ).

    LOOP AT detail-test_methods INTO DATA(method).
      DATA(method_output) = CORRESPONDING zif_aur_mail=>method_part( method ).
      method_output-name    = to_upper( method-name ).
      method_output-message = COND #( WHEN method-error IS NOT INITIAL   THEN method-error-message
                                      WHEN method-failure IS NOT INITIAL THEN method-failure-message
                                      ELSE                                    `` ).
      method_output-message = escape( val    = method_output-message
                                      format = cl_abap_format=>e_html_text ).

      INSERT method_output INTO TABLE methods.
    ENDLOOP.

    html->add_break( ).
    html->add_table( generic_data = REF #( methods )
                     formats      = VALUE #( ( column = 3 negative = abap_true ) ) ).
  ENDMETHOD.


  METHOD get_included_packages.
    LOOP AT run_result-aunit_result-test_details INTO DATA(detail).
      INSERT detail-package INTO TABLE result.
    ENDLOOP.

    SORT result BY table_line.
    DELETE ADJACENT DUPLICATES FROM result COMPARING table_line.
  ENDMETHOD.


  METHOD send_final_document.
    TRY.
        DATA(mail_client) = cl_bcs_mail_message=>create_instance( ).

        mail_client->set_sender( setting-mail_sender ).

        LOOP AT setting-mail_receiver INTO DATA(receiver).
          mail_client->add_recipient( receiver ).
        ENDLOOP.

        mail_client->set_subject( |{ TEXT-001 }: { setting-title }| ).
        mail_client->set_main( cl_bcs_mail_textpart=>create_instance( iv_content      = document_content
                                                                      iv_content_type = 'text/html' ) ).
        mail_client->send( IMPORTING et_status = DATA(sender_status) ).

        result-success = abap_true.
        LOOP AT sender_status INTO DATA(status).
          IF status-status = 'E'.
            result-error_message = |{ TEXT-002 } { status-recipient }|.
            result-success       = abap_false.
            RETURN.
          ENDIF.
        ENDLOOP.

      CATCH cx_bcs_mail INTO DATA(mail_error).
        result-error_message = cl_message_helper=>get_latest_t100_exception( mail_error )->if_message~get_text( ).
        result-success       = abap_false.

    ENDTRY.
  ENDMETHOD.


  METHOD zif_aur_mail~send.
    me->setting = setting.

    DATA(content) = create_mail_content( run_result = run_result ).

    IF setting-mail_send_only_with_error = abap_true AND run_result-aunit_result-failures = 0 AND run_result-aunit_result-asserts = 0.
      RETURN VALUE #( success = abap_true ).
    ENDIF.

    RETURN send_final_document( content ).
  ENDMETHOD.
ENDCLASS.
