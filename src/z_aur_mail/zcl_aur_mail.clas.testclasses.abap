CLASS ltc_mail DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS create_test_data
      IMPORTING !title        TYPE string
      RETURNING VALUE(result) TYPE zif_aur_runner=>run_result.

    METHODS mail_with_details    FOR TESTING.
    METHODS mail_without_details FOR TESTING.
    METHODS no_mail_by_success   FOR TESTING.
ENDCLASS.


CLASS ltc_mail IMPLEMENTATION.
  METHOD mail_with_details.
    DATA(cut) = zcl_aur_mail_factory=>create( ).

    DATA(setting) = VALUE zif_aur_runner=>setting(
        mail_details              = abap_true
        mail_sender               = zif_aur_test_config=>mail_sender
        mail_receiver             = VALUE #( ( zif_aur_test_config=>mail_receiver ) )
        mail_send_only_with_error = abap_false ).

    DATA(run_result) = create_test_data( `Test - Mail (Details)` ).

    DATA(result) = cut->send( setting    = setting
                              run_result = run_result ).

    cl_abap_unit_assert=>assert_true( result-success ).
    cl_abap_unit_assert=>assert_initial( result-error_message ).
  ENDMETHOD.


  METHOD mail_without_details.
    DATA(cut) = zcl_aur_mail_factory=>create( ).

    DATA(setting) = VALUE zif_aur_runner=>setting(
        mail_details              = abap_false
        mail_sender               = zif_aur_test_config=>mail_sender
        mail_receiver             = VALUE #( ( zif_aur_test_config=>mail_receiver ) )
        mail_send_only_with_error = abap_false ).

    DATA(run_result) = create_test_data( `Test - Mail (No Details)` ).

    DATA(result) = cut->send( setting    = setting
                              run_result = run_result ).

    cl_abap_unit_assert=>assert_true( result-success ).
    cl_abap_unit_assert=>assert_initial( result-error_message ).
  ENDMETHOD.


  METHOD no_mail_by_success.
    DATA(cut) = zcl_aur_mail_factory=>create( ).

    DATA(setting) = VALUE zif_aur_runner=>setting(
        mail_details              = abap_false
        mail_sender               = zif_aur_test_config=>mail_sender
        mail_receiver             = VALUE #( ( zif_aur_test_config=>mail_receiver ) )
        mail_send_only_with_error = abap_true ).

    DATA(run_result) = VALUE zif_aur_runner=>run_result(
        success       = abap_true
        error_message = ``
        aunit_result  = VALUE #( title          = `Don't send`
                                 system         = `S4H`
                                 client         = `100`
                                 execution_user = `CC0000000000`
                                 time           = '6.496'
                                 timestamp      = `2025-03-15T10:33:00Z`
                                 failures       = '0'
                                 errors         = '0'
                                 skipped        = '0'
                                 asserts        = '0'
                                 tests          = '1'
                                 test_details   = VALUE #(
                                     name     = ``
                                     skipped  = '0'
                                     package  = `zbs_demo_tests`
                                     hostname = `10-101-94-65`
                                     ( tests        = '1'
                                       failures     = '0'
                                       errors       = '0'
                                       asserts      = '0'
                                       timestamp    = `2025-03-15T10:33:01Z`
                                       time         = '0.268'
                                       test_methods = VALUE #(
                                           classname = `zbs_demo_tests.clas:zcl_bs_demo_api_out---ltc_read_entity`
                                           ( name    = `create_ok`
                                             time    = '0.205'
                                             asserts = '0' ) ) ) ) ) ).

    DATA(result) = cut->send( setting    = setting
                              run_result = run_result ).

    cl_abap_unit_assert=>assert_true( result-success ).
    cl_abap_unit_assert=>assert_initial( result-error_message ).
  ENDMETHOD.


  METHOD create_test_data.
    RETURN VALUE #(
        success       = abap_true
        error_message = ``
        aunit_result  = VALUE #(
            title          = title
            system         = `S4H`
            client         = `100`
            execution_user = `CC0000000000`
            time           = '6.496'
            timestamp      = `2025-03-15T10:33:00Z`
            failures       = '5'
            errors         = '1'
            skipped        = '0'
            asserts        = '5'
            tests          = '47'
            test_details   = VALUE #(
                name     = ``
                skipped  = '0'
                package  = `zbs_demo_tests`
                hostname = `10-101-94-65`
                ( tests        = '3'
                  failures     = '1'
                  errors       = '1'
                  asserts      = '1'
                  timestamp    = `2025-03-15T10:33:01Z`
                  time         = '0.268'
                  test_methods = VALUE #(
                      classname = `zbs_demo_tests.clas:zcl_bs_demo_api_out---ltc_read_entity`
                      ( name    = `create_fail`
                        time    = '0.205'
                        asserts = '0'
                        error   = VALUE #( message = ``
                                           type    = ``
                                           detail  = `` )
                        failure = VALUE #( message = ``
                                           type    = ``
                                           detail  = `` ) )
                      ( name    = `read_entity`
                        time    = '0.038'
                        asserts = '0'
                        error   = VALUE #( message = `Exception Error </IWBEP/CX_CP_LOCAL_V2>`
                                           type    = `Exception`
                                           detail  = `` )
                        failure = VALUE #( message = ``
                                           type    = ``
                                           detail  = `` ) )
                      ( name    = `read_list`
                        time    = '0.026'
                        asserts = '1'
                        error   = VALUE #( message = ``
                                           type    = ``
                                           detail  = `` )
                        failure = VALUE #( message = `Critical Assertion Error: 'Read_List: ASSERT_EQUALS'`
                                           type    = `Assert Failure`
                                           detail  = `` ) ) ) )
                ( tests        = '1'
                  failures     = '0'
                  errors       = '0'
                  asserts      = '0'
                  timestamp    = `2025-03-15T10:33:05Z`
                  time         = '0.237'
                  test_methods = VALUE #( ( classname = `zbs_demo_tests.clas:zcl_bs_demo_cds---ltc_zbs_c_companycodeout`
                                            name      = `aunit_for_cds_method`
                                            time      = '0.229'
                                            asserts   = '0'
                                            error     = VALUE #( message = ``
                                                                 type    = ``
                                                                 detail  = `` )
                                            failure   = VALUE #( message = ``
                                                                 type    = ``
                                                                 detail  = `` ) ) ) )
                ( tests        = '3'
                  failures     = '1'
                  errors       = '0'
                  asserts      = '1'
                  timestamp    = `2025-03-15T10:33:06Z`
                  time         = '0.007'
                  test_methods = VALUE #(
                      classname = `zbs_demo_tests.clas:zcl_bs_demo_funcdouble---zcl_bs_demo_funcdouble`
                      error     = VALUE #( message = ``
                                           type    = ``
                                           detail  = `` )
                      ( name    = `not_defined_case`
                        time    = '0.007'
                        asserts = '1'
                        failure = VALUE #( message = `Critical Assertion Error: 'Not_Defined_Case: ASSERT_EQUALS'`
                                           type    = `Assert Failure`
                                           detail  = `` ) )
                      ( name    = `not_defined_method`
                        time    = '0.000'
                        asserts = '0'
                        failure = VALUE #( message = ``
                                           type    = ``
                                           detail  = `` ) )
                      ( name    = `wrong_substraction`
                        time    = '0.000'
                        asserts = '0'
                        failure = VALUE #( message = ``
                                           type    = ``
                                           detail  = `` ) ) ) )
                ( tests        = '14'
                  failures     = '0'
                  errors       = '0'
                  asserts      = '0'
                  timestamp    = `2025-03-15T10:33:06Z`
                  time         = '0.002'
                  test_methods = VALUE #(
                      classname = `zbs_demo_tests.clas:zcl_bs_demo_roman_numbers---ltc_arabic_to_roman`
                      time      = '0.000'
                      asserts   = '0'
                      error     = VALUE #( message = ``
                                           type    = ``
                                           detail  = `` )
                      failure   = VALUE #( message = ``
                                           type    = ``
                                           detail  = `` )
                      ( name = `convert_0` )
                      ( name = `convert_1` )
                      ( name = `convert_1245` )
                      ( name = `convert_15` )
                      ( name = `convert_3` )
                      ( name = `convert_3299` )
                      ( name = `convert_3999` )
                      ( name = `convert_4` )
                      ( name = `convert_4000` )
                      ( name = `convert_587` )
                      ( name = `convert_611` )
                      ( name = `convert_789` )
                      ( name = `convert_9` )
                      ( name = `convert_999` ) ) )
                ( tests        = '11'
                  failures     = '0'
                  errors       = '0'
                  asserts      = '0'
                  timestamp    = `2025-03-15T10:33:06Z`
                  time         = '0.001'
                  test_methods = VALUE #(
                      classname = `zbs_demo_tests.clas:zcl_bs_demo_roman_numbers---ltc_roman_to_arabic`
                      time      = '0.000'
                      asserts   = '0'
                      error     = VALUE #( message = ``
                                           type    = ``
                                           detail  = `` )
                      failure   = VALUE #( message = ``
                                           type    = ``
                                           detail  = `` )
                      ( name = `convert_cccxlix` )
                      ( name = `convert_empty` )
                      ( name = `convert_i` )
                      ( name = `convert_iii` )
                      ( name = `convert_iv` )
                      ( name = `convert_ix` )
                      ( name = `convert_lxviii` )
                      ( name = `convert_mccxxxiv` )
                      ( name = `convert_mmmcmxcix` )
                      ( name = `convert_unknown` )
                      ( name = `convert_v` ) ) )
                ( tests        = '2'
                  failures     = '0'
                  errors       = '0'
                  asserts      = '0'
                  timestamp    = `2025-03-15T10:33:06Z`
                  time         = '0.020'
                  test_methods = VALUE #( classname = `zbs_demo_tests.clas:zcl_bs_demo_sql_double---ltc_db_access`
                                          asserts   = '0'
                                          error     = VALUE #( message = ``
                                                               type    = ``
                                                               detail  = `` )
                                          failure   = VALUE #( message = ``
                                                               type    = ``
                                                               detail  = `` )
                                          ( name = `negative_case` time = '0.011' )
                                          ( name = `positive_case` time = '0.001' ) ) )
                ( tests        = '2'
                  failures     = '1'
                  errors       = '0'
                  asserts      = '1'
                  timestamp    = `2025-03-15T10:33:06Z`
                  time         = '0.001'
                  test_methods = VALUE #(
                      classname = `zbs_demo_tests.clas:zcl_bs_demo_template---ltc_string`
                      error     = VALUE #( message = ``
                                           type    = ``
                                           detail  = `` )
                      ( name    = `first_test`
                        time    = '0.000'
                        asserts = '0'
                        failure = VALUE #( message = ``
                                           type    = ``
                                           detail  = `` ) )
                      ( name    = `second_test`
                        time    = '0.001'
                        asserts = '1'
                        failure = VALUE #( message = `Critical Assertion Error: 'Second_Test: ASSERT_EQUALS'`
                                           type    = `Assert Failure`
                                           detail  = `` ) ) ) )
                ( tests        = '2'
                  failures     = '0'
                  errors       = '0'
                  asserts      = '0'
                  timestamp    = `2025-03-15T10:33:06Z`
                  time         = '0.170'
                  test_methods = VALUE #( classname = `zbs_demo_tests.clas:zcl_bs_demo_testdouble---ltc_test_injection`
                                          asserts   = '0'
                                          error     = VALUE #( message = ``
                                                               type    = ``
                                                               detail  = `` )
                                          failure   = VALUE #( message = ``
                                                               type    = ``
                                                               detail  = `` )
                                          ( name = `without_double`
                                            time = '0.011' )
                                          ( name = `with_double` time = '0.159' ) ) )
                ( tests        = '2'
                  failures     = '1'
                  errors       = '0'
                  asserts      = '1'
                  timestamp    = `2025-03-15T10:33:06Z`
                  time         = '0.097'
                  test_methods = VALUE #(
                      classname = `zbs_demo_tests.clas:zcl_bs_demo_test_service---ltc_odata_service`
                      error     = VALUE #( message = ``
                                           type    = ``
                                           detail  = `` )
                      ( name    = `create`
                        time    = '0.076'
                        asserts = '0'
                        failure = VALUE #( message = ``
                                           type    = ``
                                           detail  = `` ) )
                      ( name    = `get_list`
                        time    = '0.021'
                        asserts = '1'
                        failure = VALUE #( message = `Critical Assertion Error: 'Get_List: ASSERT_EQUALS'`
                                           type    = `Assert Failure`
                                           detail  = `` ) ) ) )
                ( tests        = '2'
                  failures     = '0'
                  errors       = '0'
                  asserts      = '0'
                  timestamp    = `2025-03-15T10:33:06Z`
                  time         = '0.000'
                  test_methods = VALUE #( classname = `zbs_demo_tests.clas:zcl_bs_demo_unit_test---ltc_run_method`
                                          time      = '0.000'
                                          asserts   = '0'
                                          error     = VALUE #( message = ``
                                                               type    = ``
                                                               detail  = `` )
                                          failure   = VALUE #( message = ``
                                                               type    = ``
                                                               detail  = `` )
                                          ( name = `negative_case` )
                                          ( name = `positive_case` ) ) )
                ( tests        = '2'
                  failures     = '0'
                  errors       = '0'
                  asserts      = '0'
                  timestamp    = `2025-03-15T10:33:06Z`
                  time         = '0.268'
                  test_methods = VALUE #( classname = `zbs_demo_tests.clas:zcl_bs_unittest_82_uebung---ltc_test`
                                          asserts   = '0'
                                          error     = VALUE #( message = ``
                                                               type    = ``
                                                               detail  = `` )
                                          failure   = VALUE #( message = ``
                                                               type    = ``
                                                               detail  = `` )
                                          ( name = `test_f` time = '0.267' )
                                          ( name = `test_n` time = '0.001' ) ) )
                ( tests        = '1'
                  failures     = '0'
                  errors       = '0'
                  asserts      = '0'
                  timestamp    = `2025-03-15T10:33:07Z`
                  time         = '0.000'
                  test_methods = VALUE #( ( classname = `zbs_demo_tests.clas:zcl_demo_coverage---ltc_class_basic`
                                            name      = `divide_10_and_2`
                                            time      = '0.000'
                                            asserts   = '0'
                                            error     = VALUE #( message = ``
                                                                 type    = ``
                                                                 detail  = `` )
                                            failure   = VALUE #( message = ``
                                                                 type    = ``
                                                                 detail  = `` ) ) ) )
                ( tests        = '2'
                  failures     = '1'
                  errors       = '0'
                  asserts      = '1'
                  timestamp    = `2025-03-15T10:33:07Z`
                  time         = '0.001'
                  test_methods = VALUE #(
                      classname = `zbs_demo_tests.clas:zcl_demo_test---ltc_class_basic`
                      error     = VALUE #( message = ``
                                           type    = ``
                                           detail  = `` )
                      ( name    = `fail_to_select`
                        time    = '0.001'
                        asserts = '1'
                        failure = VALUE #( message = `Critical Assertion Error: 'Fail_To_Select: ASSERT_INITIAL'`
                                           type    = `Assert Failure`
                                           detail  = `` ) )
                      ( name    = `select_data_from_db`
                        time    = '0.000'
                        asserts = '0'
                        failure = VALUE #( message = ``
                                           type    = ``
                                           detail  = `` ) ) ) ) ) ) ).
  ENDMETHOD.
ENDCLASS.
