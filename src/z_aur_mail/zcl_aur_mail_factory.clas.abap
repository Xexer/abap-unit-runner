CLASS zcl_aur_mail_factory DEFINITION
  PUBLIC ABSTRACT FINAL.

  PUBLIC SECTION.
    "! Create a new instance for Mail
    "! @parameter result | Mail instance
    CLASS-METHODS create
      RETURNING VALUE(result) TYPE REF TO zif_aur_mail.

    "! Create a new instance for HTML generator
    "! @parameter result | HTML instance
    CLASS-METHODS create_html
      RETURNING VALUE(result) TYPE REF TO zif_aur_mail_html.
ENDCLASS.


CLASS zcl_aur_mail_factory IMPLEMENTATION.
  METHOD create.
    RETURN NEW zcl_aur_mail( ).
  ENDMETHOD.


  METHOD create_html.
    RETURN NEW zcl_aur_mail_html( ).
  ENDMETHOD.
ENDCLASS.
