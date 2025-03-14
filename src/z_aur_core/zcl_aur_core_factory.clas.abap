CLASS zcl_aur_core_factory DEFINITION
  PUBLIC ABSTRACT FINAL.

  PUBLIC SECTION.
    "! Create runner for ABAP Unit Tests
    "! @parameter result | Instance of runner
    CLASS-METHODS create_runner
      RETURNING VALUE(result) TYPE REF TO zif_aur_runner.

    "! Create parser for XML content
    "! @parameter result | Instance of parser
    CLASS-METHODS create_parser
      RETURNING VALUE(result) TYPE REF TO zif_aur_parser.
ENDCLASS.


CLASS zcl_aur_core_factory IMPLEMENTATION.
  METHOD create_parser.
    RETURN NEW zcl_aur_parser( ).
  ENDMETHOD.


  METHOD create_runner.
    RETURN NEW zcl_aur_runner( ).
  ENDMETHOD.
ENDCLASS.
