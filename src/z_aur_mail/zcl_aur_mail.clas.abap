CLASS zcl_aur_mail DEFINITION
  PUBLIC FINAL
  CREATE PRIVATE
  GLOBAL FRIENDS zcl_aur_mail_factory.

  PUBLIC SECTION.
    INTERFACES zif_aur_mail.

  PRIVATE SECTION.
    "! Send the document to the receiver
    "! @parameter setting          | Settings for the run
    "! @parameter document_content | Prepared mail content
    "! @parameter result           | Result for the mail
    METHODS send_final_document
      IMPORTING setting          TYPE zif_aur_runner=>setting
                document_content TYPE string
      RETURNING VALUE(result)    TYPE zif_aur_mail=>mail_result.

    "! Create mail content for result
    "! @parameter setting    | Settings for the run
    "! @parameter run_result | Test Result
    "! @parameter result     | String for Mail
    METHODS create_mail_content
      IMPORTING setting       TYPE zif_aur_runner=>setting
                run_result    TYPE zif_aur_runner=>run_result
      RETURNING VALUE(result) TYPE string.

    "! Generate HTML table from generic table
    "! @parameter generic_data | Data for table
    "! @parameter formats      | Formatter for columns
    "! @parameter result       | Table in HTML format
    METHODS generate_table
      IMPORTING generic_data  TYPE REF TO data
                formats       TYPE zif_aur_mail=>formats OPTIONAL
      RETURNING VALUE(result) TYPE string.

    "! Generate general part (Header informations)
    "! @parameter run_result | Result of ABAP Unit run
    "! @parameter result     | Content in HTML format
    METHODS generate_general_part
      IMPORTING run_result    TYPE zif_aur_runner=>run_result
      RETURNING VALUE(result) TYPE string.

    "! Get CSS for mail
    "! @parameter result | CSS content
    METHODS get_css
      RETURNING VALUE(result) TYPE string.

    "! Get different packages from run
    "! @parameter run_result | Result of ABAP Unit run
    "! @parameter result     | List of packages
    METHODS get_included_packages
      IMPORTING run_result    TYPE zif_aur_runner=>run_result
      RETURNING VALUE(result) TYPE string_table.

    "! Generate the content for the package
    "! @parameter run_result | Result of ABAP Unit run
    "! @parameter package    | Name of the package
    "! @parameter result     | HTML content
    METHODS generate_package
      IMPORTING run_result    TYPE zif_aur_runner=>run_result
                !package      TYPE string
      RETURNING VALUE(result) TYPE string.

    "! Extract the name of the global and test class
    "! @parameter name   | Name in pattern "zbs_demo_tests.clas:zcl_bs_demo_roman_numbers---ltc_arabic_to_roman"
    "! @parameter result | Parsed name for output
    METHODS extract_object_name
      IMPORTING !name         TYPE string
      RETURNING VALUE(result) TYPE string.

    "! Get the additional style for the cell
    "! @parameter field   | Content of the field
    "! @parameter index   | Index of the column
    "! @parameter header  | X = Header line, '' = Content line
    "! @parameter formats | Format settings for table
    "! @parameter result  | Finished style
    METHODS get_cell_style
      IMPORTING !field        TYPE any
                !index        TYPE syst-index
                !header       TYPE abap_bool
                formats       TYPE zif_aur_mail=>formats
      RETURNING VALUE(result) TYPE string.
ENDCLASS.


CLASS zcl_aur_mail IMPLEMENTATION.
  METHOD zif_aur_mail~send.
    DATA(content) = create_mail_content( setting    = setting
                                         run_result = run_result ).

    IF setting-mail_send_only_with_error = abap_true AND run_result-aunit_result-failures = 0 OR run_result-aunit_result-asserts = 0.
      RETURN VALUE #( success = abap_true ).
    ENDIF.

    RETURN send_final_document( setting          = setting
                                document_content = content ).
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


  METHOD create_mail_content.
    DATA(body) = ``.
    DATA(css) = get_css( ).

    body &&= generate_general_part( run_result ).

    DATA(packages) = get_included_packages( run_result ).
    LOOP AT packages INTO DATA(package).
      body &&= |<br><h1>{ TEXT-004 }: { to_upper( package ) }</h1>{ generate_package( run_result = run_result
                                                                                      package    = package ) }|.
    ENDLOOP.

    RETURN |<!DOCTYPE html lang="en">| &
           |<head>| &
           |  <style>| &
           |    { css }| &
           |  </style>| &
           |</head>| &
           |<body>| &
           |  { body }| &
           |</body>| &
           |</html>|.
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

    result &&= |<h1>{ TEXT-003 }</h1>{ generate_table(
                                           generic_data = REF #( general )
                                           formats      = VALUE #( ( column = 7 negative = abap_true )
                                                                   ( column = 8 negative = abap_true )
                                                                   ( column = 10 negative = abap_true )
                                                                   ( column = 11 positive = abap_true ) ) ) }|.
  ENDMETHOD.


  METHOD generate_table.
    FIELD-SYMBOLS <table> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <line>  TYPE any.

    ASSIGN generic_data->* TO <table>.
    DATA(header) = abap_true.

    LOOP AT <table> ASSIGNING <line>.
      result &&= `<tr>`.

      DO.
        DATA(index) = sy-index.
        ASSIGN COMPONENT index OF STRUCTURE <line> TO FIELD-SYMBOL(<field>).
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.

        DATA(style) = get_cell_style( field   = <field>
                                      index   = index
                                      header  = header
                                      formats = formats ).

        IF header = abap_true.
          result &&= |<th style="{ style }">{ <field> }</th>|.
        ELSE.
          result &&= |<td style="{ style }">{ <field> }</td>|.
        ENDIF.
      ENDDO.

      result &&= `</tr>`.
      header = abap_false.
    ENDLOOP.

    result = |<table>{ result }</table>|.
  ENDMETHOD.


  METHOD get_cell_style.
    TRY.
        DATA(format) = formats[ column = index ].

      CATCH cx_sy_itab_line_not_found.
        RETURN.
    ENDTRY.

    IF header = abap_true.
      RETURN.
    ENDIF.

    IF field = 0.
      RETURN.
    ENDIF.

    IF format-negative = abap_true.
      result = |background-color: { zif_aur_mail=>hex_color-negative };|.
    ELSEIF format-positive = abap_true.
      result = |background-color: { zif_aur_mail=>hex_color-positive };|.
    ENDIF.
  ENDMETHOD.


  METHOD get_css.
    DATA(css) = `table { border-collapse: collapse; } `.
    css &&= `td, th { padding: 5px 12px; } `.
    css &&= |th \{ background-color: { zif_aur_mail=>hex_color-table_back }; color: { zif_aur_mail=>hex_color-table_text }; \} |.

    RETURN css.
  ENDMETHOD.


  METHOD get_included_packages.
    LOOP AT run_result-aunit_result-test_details INTO DATA(detail).
      INSERT detail-package INTO TABLE result.
    ENDLOOP.

    SORT result BY table_line.
    DELETE ADJACENT DUPLICATES FROM result COMPARING table_line.
  ENDMETHOD.


  METHOD generate_package.
    LOOP AT run_result-aunit_result-test_details INTO DATA(detail) WHERE package = package.
      DATA(object_name) = ``.
      DATA(objects) = VALUE zif_aur_mail=>object_parts( ( tests     = TEXT-015
                                                          failures  = TEXT-011
                                                          errors    = TEXT-012
                                                          skipped   = TEXT-013
                                                          asserts   = TEXT-014
                                                          timestamp = TEXT-010
                                                          time      = TEXT-016 ) ).
      INSERT CORRESPONDING #( detail ) INTO TABLE objects.

      DATA(methods) = VALUE zif_aur_mail=>method_parts( ( name = TEXT-017 time = TEXT-016 asserts = TEXT-014 ) ).
      LOOP AT detail-test_methods INTO DATA(method).
        IF sy-tabix = 1.
          object_name = extract_object_name( method-classname ).
        ENDIF.

        method-name = to_upper( method-name ).
        INSERT CORRESPONDING #( method ) INTO TABLE methods.
      ENDLOOP.

      DATA(object_output) = generate_table( generic_data = REF #( objects )
                                            formats      = VALUE #( ( column = 1 positive = abap_true )
                                                                    ( column = 2 negative = abap_true )
                                                                    ( column = 3 negative = abap_true )
                                                                    ( column = 5 negative = abap_true ) ) ).
      DATA(method_output) = generate_table( generic_data = REF #( methods )
                                            formats      = VALUE #( ( column = 3 negative = abap_true ) ) ).

      result &&= |<h3>{ object_name }</h3>{ object_output }<br>{ method_output }|.
    ENDLOOP.
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
ENDCLASS.
