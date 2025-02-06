CLASS zcl_aur_core_factory DEFINITION
  PUBLIC ABSTRACT FINAL.

  PUBLIC SECTION.
    CLASS-METHODS create_runner
      RETURNING VALUE(result) TYPE REF TO zif_aur_runner.

    CLASS-METHODS create_parser
      RETURNING VALUE(result) TYPE REF TO zif_aur_parser.
ENDCLASS.


CLASS zcl_aur_core_factory IMPLEMENTATION.
  METHOD create_runner.
    RETURN NEW zcl_aur_runner( ).
  ENDMETHOD.


  METHOD create_parser.
    RETURN NEW zcl_aur_parser( ).
  ENDMETHOD.
ENDCLASS.
