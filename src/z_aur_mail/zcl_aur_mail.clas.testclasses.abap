CLASS ltc_test_mail DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    DATA cut TYPE REF TO zcl_aur_mail.

    METHODS setup.

    METHODS generic_table_without_style FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS zcl_aur_mail DEFINITION LOCAL FRIENDS ltc_test_mail.

CLASS ltc_test_mail IMPLEMENTATION.
  METHOD setup.
    cut = NEW zcl_aur_mail( ).
  ENDMETHOD.


  METHOD generic_table_without_style.
    DATA(methods) = VALUE zif_aur_mail=>method_parts( ( name = 'test' time = '0.001' asserts = 0 ) ).

    DATA(formats) = VALUE zif_aur_mail=>formats( ( column = 3 negative = abap_true ) ).

    DATA(result) = cut->generate_table( generic_data = REF #( methods )
                                        formats      = formats ).

    cl_abap_unit_assert=>assert_equals(
        exp = `<table><tr><th style="">test</th><th style="">0.001</th><th style="">0 </th></tr></table>`
        act = result ).
  ENDMETHOD.
ENDCLASS.
