CLASS ltc_runner DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.


    METHODS run_for_class  FOR TESTING.
    METHODS no_destination FOR TESTING.
ENDCLASS.


CLASS ltc_runner IMPLEMENTATION.
  METHOD run_for_class.
    DATA(cut) = zcl_aur_core_factory=>create_runner( ).
    DATA(setting) = VALUE zif_aur_runner=>setting( cloud_destination   = zif_aur_test_config=>aunit_destination
                                                   title               = `Unit Test`
                                                   scope_own           = abap_true
                                                   scope_foreign       = abap_true
                                                   risklevel_harmless  = abap_true
                                                   risklevel_dangerous = abap_true
                                                   duration_short      = abap_true
                                                   duration_medium     = abap_true
                                                   duration_long       = abap_true
                                                   classes             = VALUE #( ( 'ZCL_AUR_PAYLOAD' ) ) ).

    DATA(result) = cut->execute( setting ).

    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = result-aunit_result-tests ).
  ENDMETHOD.


  METHOD no_destination.
    DATA(cut) = zcl_aur_core_factory=>create_runner( ).

    DATA(result) = cut->execute( VALUE #( ) ).

    cl_abap_unit_assert=>assert_not_initial( result-error_message ).
  ENDMETHOD.
ENDCLASS.
