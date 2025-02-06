CLASS zcl_aur_parser DEFINITION
  PUBLIC FINAL
  CREATE PRIVATE
  GLOBAL FRIENDS zcl_aur_core_factory.

  PUBLIC SECTION.
    INTERFACES zif_aur_parser.

ENDCLASS.


CLASS zcl_aur_parser IMPLEMENTATION.
  METHOD zif_aur_parser~parse_aunit_run.
    DATA(binary) = xco_cp=>string( to_parse )->as_xstring( xco_cp_character=>code_page->utf_8 )->value.
    DATA(reader) = cl_sxml_string_reader=>create( binary ).

    DO.
      TRY.
          reader->next_node( ).
        CATCH cx_sxml_parse_error.
          EXIT.
      ENDTRY.

      IF reader->node_type <> if_sxml_node=>co_nt_element_open.
        CONTINUE.
      ENDIF.

      TRY.
          CASE to_upper( reader->name ).
            WHEN 'RUN'.
              reader->get_attribute_value( `title` ).
              result-title = reader->value.

              reader->get_attribute_value( `context` ).
              result-context = reader->value.

            WHEN 'PROGRESS'.
              reader->get_attribute_value( `status` ).
              result-progress_status = reader->value.

              reader->get_attribute_value( `percentage` ).
              result-progress_percentage = reader->value.

            WHEN 'EXECUTEDBY'.
              reader->get_attribute_value( `user` ).
              result-execution_user = reader->value.

            WHEN 'TIME'.
              reader->get_attribute_value( `started` ).
              result-start = reader->value.

              reader->get_attribute_value( `ended` ).
              result-end = reader->value.

            WHEN 'LINK'.
              reader->get_attribute_value( `href` ).
              result-result_link = reader->value.

          ENDCASE.

        CATCH cx_root.
      ENDTRY.
    ENDDO.
  ENDMETHOD.


  METHOD zif_aur_parser~parse_aunit_result.
    DATA(binary) = xco_cp=>string( to_parse )->as_xstring( xco_cp_character=>code_page->utf_8 )->value.
    DATA(reader) = cl_sxml_string_reader=>create( binary ).

    DO.
      TRY.
          reader->next_node( ).
        CATCH cx_sxml_parse_error.
          EXIT.
      ENDTRY.

      IF reader->node_type <> if_sxml_node=>co_nt_element_open.
        CONTINUE.
      ENDIF.

      TRY.
          CASE to_upper( reader->name ).
            WHEN 'TESTSUITES'.
              reader->get_attribute_value( `title` ).
              result-title = reader->value.

              reader->get_attribute_value( `system` ).
              result-system = reader->value.

              reader->get_attribute_value( `client` ).
              result-client = reader->value.

              reader->get_attribute_value( `executedBy` ).
              result-execution_user = reader->value.

              reader->get_attribute_value( `time` ).
              result-time = reader->value.

              reader->get_attribute_value( `timestamp` ).
              result-timestamp = reader->value.

              reader->get_attribute_value( `failures` ).
              result-failures = reader->value.

              reader->get_attribute_value( `errors` ).
              result-errors = reader->value.

              reader->get_attribute_value( `skipped` ).
              result-skipped = reader->value.

              reader->get_attribute_value( `asserts` ).
              result-asserts = reader->value.

              reader->get_attribute_value( `tests` ).
              result-tests = reader->value.

            WHEN 'TESTSUITE'.
              INSERT INITIAL LINE INTO TABLE result-test_details REFERENCE INTO DATA(test).

              reader->get_attribute_value( `name` ).
              test->name = reader->value.

              reader->get_attribute_value( `tests` ).
              test->tests = reader->value.

              reader->get_attribute_value( `failures` ).
              test->failures = reader->value.

              reader->get_attribute_value( `errors` ).
              test->errors = reader->value.

              reader->get_attribute_value( `skipped` ).
              test->skipped = reader->value.

              reader->get_attribute_value( `asserts` ).
              test->asserts = reader->value.

              reader->get_attribute_value( `package` ).
              test->package = reader->value.

              reader->get_attribute_value( `timestamp` ).
              test->timestamp = reader->value.

              reader->get_attribute_value( `time` ).
              test->time = reader->value.

              reader->get_attribute_value( `hostname` ).
              test->hostname = reader->value.

            WHEN 'TESTCASE'.
              INSERT INITIAL LINE INTO TABLE test->test_methods REFERENCE INTO DATA(method).

              reader->get_attribute_value( `classname` ).
              method->classname = reader->value.

              reader->get_attribute_value( `name` ).
              method->name = reader->value.

              reader->get_attribute_value( `time` ).
              method->time = reader->value.

              reader->get_attribute_value( `asserts` ).
              method->asserts = reader->value.
          ENDCASE.

        CATCH cx_root.
      ENDTRY.
    ENDDO.
  ENDMETHOD.
ENDCLASS.
