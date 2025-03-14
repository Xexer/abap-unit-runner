CLASS ltc_parser DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS parse_aunit_result FOR TESTING.
    METHODS parse_aunit_run    FOR TESTING.
ENDCLASS.


CLASS ltc_parser IMPLEMENTATION.
  METHOD parse_aunit_result.
    DATA(parser) = zcl_aur_core_factory=>create_parser( ).

    DATA(xml_run) = |<?xml version="1.0" encoding="utf-8"?><aunit:run title="Testrun This" context="AIE Integration Test" xmlns:aunit="http://www.sap.com/adt/api/aunit"><aunit:progress status="FINISHED" percentage="100"/><aunit:executedBy user="CC00| &&
|00000000"/><aunit:time started="2025-03-14T19:18:44Z" ended="2025-03-14T19:18:44Z"/><atom:link href="/sap/bc/adt/api/abapunit/results/CA8E4BFB46A01FE080A124953152B18D" rel="http://www.sap.com/adt/relations/api/abapunit/run-result" type="application| &&
|/vnd.sap.adt.api.junit.run-result.v1+xml" title="Run Result (JUnit Format)" xmlns:atom="http://www.w3.org/2005/Atom"/><atom:link href="/sap/bc/adt/api/abapunit/results/CA8E4BFB46A01FE080A124953152B18D" rel="http://www.sap.com/adt/relations/api/abap| &&
|unit/run-result" type="application/vnd.sap.adt.api.abapunit.run-result.v1+xml" title="Run Result (ABAP Unit Format)" xmlns:atom="http://www.w3.org/2005/Atom"/></aunit:run>|.

    DATA(expected) = VALUE zif_aur_runner=>aunit_run(
        title               = `Testrun This`
        context             = `AIE Integration Test`
        progress_status     = `FINISHED`
        progress_percentage = '100'
        execution_user      = `CC0000000000`
        start               = `2025-03-14T19:18:44Z`
        end                 = `2025-03-14T19:18:44Z`
        result_link         = `/sap/bc/adt/api/abapunit/results/CA8E4BFB46A01FE080A124953152B18D` ).

    DATA(result) = parser->parse_aunit_run( xml_run ).

    cl_abap_unit_assert=>assert_equals( exp = expected
                                        act = result ).
  ENDMETHOD.


  METHOD parse_aunit_run.
    DATA(parser) = zcl_aur_core_factory=>create_parser( ).

    DATA(xml_run) = |<?xml version="1.0" encoding="utf-8"?><testsuites title="Testrun This" system="S4H" client="100" executedBy="CC0000000000" time="0.132" timestamp="2025-03-14T19:18:44Z" failures="0" errors="0" skipped="0" asserts="0" tests="25">| &&
|<testsuite name="" tests="14" failures="0" errors="0" skipped="0" asserts="0" package="zbs_demo_tests" timestamp="2025-03-14T19:18:44Z" time="0.001" hostname="00-000-000-00"><testcase classname="zbs_demo_tests.clas:zcl_bs_demo_roman_numbers---ltc_a| &&
|rabic_to_roman" name="convert_0" time="0.000" asserts="0"/><testcase classname="zbs_demo_tests.clas:zcl_bs_demo_roman_numbers---ltc_arabic_to_roman" name="convert_1" time="0.000" asserts="0"/><testcase classname="zbs_demo_tests.clas:zcl_bs_demo_rom| &&
|an_numbers---ltc_arabic_to_roman" name="convert_1245" time="0.000" asserts="0"/><testcase classname="zbs_demo_tests.clas:zcl_bs_demo_roman_numbers---ltc_arabic_to_roman" name="convert_15" time="0.000" asserts="0"/><testcase classname="zbs_demo_test| &&
|s.clas:zcl_bs_demo_roman_numbers---ltc_arabic_to_roman" name="convert_3" time="0.000" asserts="0"/><testcase classname="zbs_demo_tests.clas:zcl_bs_demo_roman_numbers---ltc_arabic_to_roman" name="convert_3299" time="0.000" asserts="0"/><testcase cla| &&
|ssname="zbs_demo_tests.clas:zcl_bs_demo_roman_numbers---ltc_arabic_to_roman" name="convert_3999" time="0.000" asserts="0"/><testcase classname="zbs_demo_tests.clas:zcl_bs_demo_roman_numbers---ltc_arabic_to_roman" name="convert_4" time="0.000" asser| &&
|ts="0"/><testcase classname="zbs_demo_tests.clas:zcl_bs_demo_roman_numbers---ltc_arabic_to_roman" name="convert_4000" time="0.000" asserts="0"/><testcase classname="zbs_demo_tests.clas:zcl_bs_demo_roman_numbers---ltc_arabic_to_roman" name="convert_| &&
|587" time="0.000" asserts="0"/><testcase classname="zbs_demo_tests.clas:zcl_bs_demo_roman_numbers---ltc_arabic_to_roman" name="convert_611" time="0.000" asserts="0"/><testcase classname="zbs_demo_tests.clas:zcl_bs_demo_roman_numbers---ltc_arabic_to| &&
|_roman" name="convert_789" time="0.000" asserts="0"/><testcase classname="zbs_demo_tests.clas:zcl_bs_demo_roman_numbers---ltc_arabic_to_roman" name="convert_9" time="0.000" asserts="0"/><testcase classname="zbs_demo_tests.clas:zcl_bs_demo_roman_num| &&
|bers---ltc_arabic_to_roman" name="convert_999" time="0.000" asserts="0"/></testsuite><testsuite name="" tests="11" failures="0" errors="0" skipped="0" asserts="0" package="zbs_demo_tests" timestamp="2025-03-14T19:18:44Z" time="0.001" hostname="00-0| &&
|00-000-00"><testcase classname="zbs_demo_tests.clas:zcl_bs_demo_roman_numbers---ltc_roman_to_arabic" name="convert_cccxlix" time="0.000" asserts="0"/><testcase classname="zbs_demo_tests.clas:zcl_bs_demo_roman_numbers---ltc_roman_to_arabic" name="co| &&
|nvert_empty" time="0.000" asserts="0"/><testcase classname="zbs_demo_tests.clas:zcl_bs_demo_roman_numbers---ltc_roman_to_arabic" name="convert_i" time="0.000" asserts="0"/><testcase classname="zbs_demo_tests.clas:zcl_bs_demo_roman_numbers---ltc_rom| &&
|an_to_arabic" name="convert_iii" time="0.000" asserts="0"/><testcase classname="zbs_demo_tests.clas:zcl_bs_demo_roman_numbers---ltc_roman_to_arabic" name="convert_iv" time="0.000" asserts="0"/><testcase classname="zbs_demo_tests.clas:zcl_bs_demo_ro| &&
|man_numbers---ltc_roman_to_arabic" name="convert_ix" time="0.000" asserts="0"/><testcase classname="zbs_demo_tests.clas:zcl_bs_demo_roman_numbers---ltc_roman_to_arabic" name="convert_lxviii" time="0.000" asserts="0"/><testcase classname="zbs_demo_t| &&
|ests.clas:zcl_bs_demo_roman_numbers---ltc_roman_to_arabic" name="convert_mccxxxiv" time="0.000" asserts="0"/><testcase classname="zbs_demo_tests.clas:zcl_bs_demo_roman_numbers---ltc_roman_to_arabic" name="convert_mmmcmxcix" time="0.000" asserts="0"| &&
|/><testcase classname="zbs_demo_tests.clas:zcl_bs_demo_roman_numbers---ltc_roman_to_arabic" name="convert_unknown" time="0.000" asserts="0"/><testcase classname="zbs_demo_tests.clas:zcl_bs_demo_roman_numbers---ltc_roman_to_arabic" name="convert_v" | &&
|time="0.000" asserts="0"/></testsuite></testsuites>|.

    DATA(expected) = VALUE zif_aur_runner=>aunit_result(
        title          = `Testrun This`
        system         = `S4H`
        client         = `100`
        execution_user = `CC0000000000`
        time           = '0.132'
        timestamp      = `2025-03-14T19:18:44Z`
        failures       = '0'
        errors         = '0'
        skipped        = '0'
        asserts        = '0'
        tests          = '25'
        test_details   = VALUE #(
            name      = ``
            failures  = '0'
            errors    = '0'
            skipped   = '0'
            asserts   = '0'
            package   = `zbs_demo_tests`
            timestamp = `2025-03-14T19:18:44Z`
            time      = '0.001'
            hostname  = `00-000-000-00`
            ( tests        = '14'
              test_methods = VALUE #( classname = `zbs_demo_tests.clas:zcl_bs_demo_roman_numbers---ltc_arabic_to_roman`
                                      time      = '0.000'
                                      asserts   = '0'
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
              test_methods = VALUE #( classname = `zbs_demo_tests.clas:zcl_bs_demo_roman_numbers---ltc_roman_to_arabic`
                                      time      = '0.000'
                                      asserts   = '0'
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
                                      ( name = `convert_v` ) ) ) ) ).

    DATA(result) = parser->parse_aunit_result( xml_run ).

    cl_abap_unit_assert=>assert_equals( exp = expected
                                        act = result ).
  ENDMETHOD.
ENDCLASS.
