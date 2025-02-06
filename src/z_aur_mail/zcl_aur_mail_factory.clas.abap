CLASS zcl_aur_mail_factory DEFINITION
  PUBLIC ABSTRACT FINAL.

  PUBLIC SECTION.
    CLASS-METHODS create
      RETURNING VALUE(result) TYPE REF TO zif_aur_mail.
ENDCLASS.


CLASS zcl_aur_mail_factory IMPLEMENTATION.
  METHOD create.
    RETURN NEW zcl_aur_mail( ).
  ENDMETHOD.
ENDCLASS.
