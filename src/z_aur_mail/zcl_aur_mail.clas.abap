CLASS zcl_aur_mail DEFINITION
  PUBLIC FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    INTERFACES zif_aur_mail.

    CLASS-METHODS create
      RETURNING VALUE(result) TYPE REF TO zif_aur_mail.
ENDCLASS.


CLASS zcl_aur_mail IMPLEMENTATION.
  METHOD create.
    RETURN NEW zcl_aur_mail( ).
  ENDMETHOD.


  METHOD zif_aur_mail~send.
  ENDMETHOD.
ENDCLASS.
