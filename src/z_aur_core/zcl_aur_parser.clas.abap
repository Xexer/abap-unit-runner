CLASS zcl_aur_parser DEFINITION
  PUBLIC FINAL
  CREATE PRIVATE
  GLOBAL FRIENDS zcl_aur_core_factory.

  PUBLIC SECTION.
    INTERFACES zif_aur_parser.

  PRIVATE SECTION.
    TYPES: BEGIN OF mapping,
             attribute TYPE string,
             field     TYPE c LENGTH 30,
           END OF mapping.
    TYPES mappings TYPE STANDARD TABLE OF mapping WITH EMPTY KEY.

    "! Creates an instance of the XML reader class
    "! @parameter to_parse | XML String
    "! @parameter result   | XML Reader object
    METHODS get_reader_from_xml
      IMPORTING to_parse      TYPE string
      RETURNING VALUE(result) TYPE REF TO if_sxml_reader.

    "! Read and map attributes to structure
    "! @parameter mappings  | <p class="shorttext synchronized"></p>
    "! @parameter structure | Reference to data structure
    "! @parameter open_node | Open node for attributes
    METHODS fill_result
      IMPORTING mappings   TYPE mappings
                !structure TYPE REF TO data
                open_node  TYPE REF TO if_sxml_open_element.
ENDCLASS.


CLASS zcl_aur_parser IMPLEMENTATION.
  METHOD zif_aur_parser~parse_aunit_result.
    DATA(reader) = get_reader_from_xml( to_parse ).

    DO.
      DATA(node) = reader->read_next_node( ).
      IF reader->node_type = if_sxml_node=>co_nt_final.
        EXIT.
      ENDIF.

      IF reader->node_type <> if_sxml_node=>co_nt_element_open.
        CONTINUE.
      ENDIF.

      DATA(open_node) = CAST if_sxml_open_element( node ).

      CASE to_upper( reader->name ).
        WHEN 'TESTSUITES'.
          fill_result( mappings  = VALUE #( ( attribute = `title` )
                                            ( attribute = `system` )
                                            ( attribute = `client` )
                                            ( attribute = `executedBy` field = 'EXECUTION_USER' )
                                            ( attribute = `time` )
                                            ( attribute = `timestamp` )
                                            ( attribute = `failures` )
                                            ( attribute = `errors` )
                                            ( attribute = `skipped` )
                                            ( attribute = `asserts` )
                                            ( attribute = `tests` ) )
                       structure = REF #( result )
                       open_node = open_node ).

        WHEN 'TESTSUITE'.
          INSERT INITIAL LINE INTO TABLE result-test_details REFERENCE INTO DATA(test).
          fill_result( mappings  = VALUE #( ( attribute = `name` )
                                            ( attribute = `tests` )
                                            ( attribute = `failures` )
                                            ( attribute = `errors` )
                                            ( attribute = `skipped` )
                                            ( attribute = `asserts` )
                                            ( attribute = `package` )
                                            ( attribute = `timestamp` )
                                            ( attribute = `time` )
                                            ( attribute = `hostname` ) )
                       structure = test
                       open_node = open_node ).

        WHEN 'TESTCASE'.
          INSERT INITIAL LINE INTO TABLE test->test_methods REFERENCE INTO DATA(method).
          fill_result( mappings  = VALUE #( ( attribute = `classname` )
                                            ( attribute = `name` )
                                            ( attribute = `time` )
                                            ( attribute = `asserts` ) )
                       structure = method
                       open_node = open_node ).

      ENDCASE.
    ENDDO.
  ENDMETHOD.


  METHOD zif_aur_parser~parse_aunit_run.
    DATA(reader) = get_reader_from_xml( to_parse ).

    DO.
      DATA(node) = reader->read_next_node( ).
      IF reader->node_type = if_sxml_node=>co_nt_final.
        EXIT.
      ENDIF.

      IF reader->node_type <> if_sxml_node=>co_nt_element_open.
        CONTINUE.
      ENDIF.

      DATA(open_node) = CAST if_sxml_open_element( node ).

      CASE to_upper( reader->name ).
        WHEN 'RUN'.
          fill_result( mappings  = VALUE #( ( attribute = `title` )
                                            ( attribute = `context` ) )
                       structure = REF #( result )
                       open_node = open_node ).

        WHEN 'PROGRESS'.
          fill_result( mappings  = VALUE #( ( attribute = `status` field = 'PROGRESS_STATUS' )
                                            ( attribute = `percentage` field = 'PROGRESS_PERCENTAGE' ) )
                       structure = REF #( result )
                       open_node = open_node ).

        WHEN 'EXECUTEDBY'.
          fill_result( mappings  = VALUE #( ( attribute = `user` field = 'EXECUTION_USER' ) )
                       structure = REF #( result )
                       open_node = open_node ).

        WHEN 'TIME'.
          fill_result( mappings  = VALUE #( ( attribute = `started` field = 'START' )
                                            ( attribute = `ended` field = 'END' ) )
                       structure = REF #( result )
                       open_node = open_node ).

        WHEN 'LINK'.
          fill_result( mappings  = VALUE #( ( attribute = `href` field = 'RESULT_LINK' ) )
                       structure = REF #( result )
                       open_node = open_node ).

      ENDCASE.
    ENDDO.
  ENDMETHOD.


  METHOD fill_result.
    LOOP AT mappings REFERENCE INTO DATA(mapping).
      DATA(result_field) = COND #( WHEN mapping->field IS NOT INITIAL
                                   THEN mapping->field
                                   ELSE to_upper( mapping->attribute ) ).

      ASSIGN COMPONENT result_field OF STRUCTURE structure->* TO FIELD-SYMBOL(<field>).
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      TRY.
          <field> = open_node->get_attribute_value( mapping->attribute )->get_value( ).
        CATCH cx_root.
          CLEAR <field>.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_reader_from_xml.
    DATA(binary) = xco_cp=>string( to_parse )->as_xstring( xco_cp_character=>code_page->utf_8 )->value.
    RETURN cl_sxml_string_reader=>create( binary ).
  ENDMETHOD.
ENDCLASS.
