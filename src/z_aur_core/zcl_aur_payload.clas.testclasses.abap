CLASS ltc_xml DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS convert_with_package FOR TESTING.
    METHODS convert_with_class   FOR TESTING.
ENDCLASS.


CLASS ltc_xml IMPLEMENTATION.
  METHOD convert_with_package.
    DATA(setting) = VALUE zif_aur_runner=>setting( title              = `Testconversion`
                                                   scope_own          = abap_true
                                                   risklevel_harmless = abap_true
                                                   duration_short     = abap_true
                                                   packages           = VALUE #( ( 'ZPACK' ) ) ).

    DATA(expected) = |<?xml version="1.0" encoding="UTF-8"?><aunit:run title="Testconversion" context="AIE Integration Test" xmlns:aunit="http://www.sap.com/adt/api/aunit"><aunit:options><aunit:measurements type="none"/><aunit:scope ownTests="true" | &&
|foreignTests="false"/><aunit:riskLevel harmless="true" dangerous="false" critical="false"/><aunit:duration short="true" medium="false" long="false"/></aunit:options><osl:objectSet xsi:type="unionSet" xmlns:osl="http://www.sap.com/api/osl" xmlns:xsi| &&
|="http://www.w3.org/2001/XMLSchema-instance"><osl:set xsi:type="osl:packageSet"><osl:package includeSubpackages="true" name="ZPACK"/></osl:set><osl:set xsi:type="osl:flatObjectSet"/></osl:objectSet></aunit:run>|.

    DATA(result) = zcl_aur_core_factory=>create_payload( )->get_xml_payload( setting ).

    cl_abap_unit_assert=>assert_equals( exp = expected
                                        act = result ).
  ENDMETHOD.


  METHOD convert_with_class.
    DATA(setting) = VALUE zif_aur_runner=>setting( title               = `Testconversion`
                                                   scope_own           = abap_true
                                                   scope_foreign       = abap_true
                                                   risklevel_harmless  = abap_true
                                                   risklevel_dangerous = abap_true
                                                   duration_short      = abap_true
                                                   duration_medium     = abap_true
                                                   duration_long       = abap_true
                                                   classes             = VALUE #( ( 'ZCL_ABC' ) ) ).

    DATA(expected) = |<?xml version="1.0" encoding="UTF-8"?><aunit:run title="Testconversion" context="AIE Integration Test" xmlns:aunit="http://www.sap.com/adt/api/aunit"><aunit:options><aunit:measurements type="none"/><aunit:scope ownTests="true" | &&
|foreignTests="true"/><aunit:riskLevel harmless="true" dangerous="true" critical="false"/><aunit:duration short="true" medium="true" long="true"/></aunit:options><osl:objectSet xsi:type="unionSet" xmlns:osl="http://www.sap.com/api/osl" xmlns:xsi="ht| &&
|tp://www.w3.org/2001/XMLSchema-instance"><osl:set xsi:type="osl:packageSet"/><osl:set xsi:type="osl:flatObjectSet"><osl:object name="ZCL_ABC" type="CLAS"/></osl:set></osl:objectSet></aunit:run>|.

    DATA(result) = zcl_aur_core_factory=>create_payload( )->get_xml_payload( setting ).

    cl_abap_unit_assert=>assert_equals( exp = expected
                                        act = result ).
  ENDMETHOD.
ENDCLASS.
