CLASS zcl_aur_mail_html DEFINITION
  PUBLIC FINAL
  CREATE PRIVATE
  GLOBAL FRIENDS zcl_aur_mail_factory.

  PUBLIC SECTION.
    INTERFACES zif_aur_mail_html.

  PRIVATE SECTION.
    DATA document_parts TYPE string_table.

    "! Get CSS for mail
    "! @parameter result | CSS content
    METHODS get_css
      RETURNING VALUE(result) TYPE string.

    "! Get the additional style for the cell
    "! @parameter field   | Content of the field
    "! @parameter index   | Index of the column
    "! @parameter header  | X = Header line, '' = Content line
    "! @parameter formats | Format settings for table
    "! @parameter result  | Finished style
    METHODS get_cell_style
      IMPORTING !field        TYPE any
                !index        TYPE syst-index
                !header       TYPE abap_bool
                formats       TYPE zif_aur_mail_html=>formats
      RETURNING VALUE(result) TYPE string.
ENDCLASS.


CLASS zcl_aur_mail_html IMPLEMENTATION.
  METHOD zif_aur_mail_html~finish_document.
    DATA(css) = get_css( ).

    DATA(body) = ``.
    LOOP AT document_parts REFERENCE INTO DATA(part).
      body &&= part->*.
    ENDLOOP.

    RETURN |<!DOCTYPE html lang="en">| &
           |<head>| &
           |  <style>| &
           |    { css }| &
           |  </style>| &
           |</head>| &
           |<body>| &
           |  { body }| &
           |</body>| &
           |</html>|.
  ENDMETHOD.


  METHOD zif_aur_mail_html~add_table.
    FIELD-SYMBOLS <table> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <line>  TYPE any.

    ASSIGN generic_data->* TO <table>.
    DATA(header) = abap_true.
    DATA(content) = ``.

    LOOP AT <table> ASSIGNING <line>.
      content &&= `<tr>`.

      DO.
        DATA(index) = sy-index.
        ASSIGN COMPONENT index OF STRUCTURE <line> TO FIELD-SYMBOL(<field>).
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.

        DATA(style) = get_cell_style( field   = <field>
                                      index   = index
                                      header  = header
                                      formats = formats ).

        IF header = abap_true.
          content &&= |<th style="{ style }">{ <field> }</th>|.
        ELSE.
          content &&= |<td style="{ style }">{ <field> }</td>|.
        ENDIF.
      ENDDO.

      content &&= `</tr>`.
      header = abap_false.
    ENDLOOP.

    INSERT |<table>{ content }</table>| INTO TABLE document_parts.
  ENDMETHOD.


  METHOD get_cell_style.
    TRY.
        DATA(format) = formats[ column = index ].

      CATCH cx_sy_itab_line_not_found.
        RETURN.
    ENDTRY.

    IF header = abap_true.
      RETURN.
    ENDIF.

    IF field = 0.
      RETURN.
    ENDIF.

    IF format-negative = abap_true.
      result = |background-color: { zif_aur_mail_html=>hex_color-negative };|.
    ELSEIF format-positive = abap_true.
      result = |background-color: { zif_aur_mail_html=>hex_color-positive };|.
    ENDIF.
  ENDMETHOD.


  METHOD get_css.
    DATA(css) = `table { border-collapse: collapse; } `.
    css &&= `td, th { padding: 5px 12px; } `.
    css &&= |td, th \{ border: 1px solid { zif_aur_mail_html=>hex_color-table_border }; \} |.
    css &&= |th \{ background-color: { zif_aur_mail_html=>hex_color-table_back }; color: { zif_aur_mail_html=>hex_color-table_text }; \} |.
    css &&= |.head_color \{ color: { zif_aur_mail_html=>hex_color-head_color } \} |.

    RETURN css.
  ENDMETHOD.


  METHOD zif_aur_mail_html~add_break.
    DATA(content) = ``.

    DO times TIMES.
      content &&= `<br>`.
    ENDDO.

    INSERT content INTO TABLE document_parts.
  ENDMETHOD.


  METHOD zif_aur_mail_html~add_big_header.
    INSERT |<h1 class="head_color">{ text }</h1>| INTO TABLE document_parts.
  ENDMETHOD.


  METHOD zif_aur_mail_html~add_medium_header.
    INSERT |<h3>{ text }</h3>| INTO TABLE document_parts.
  ENDMETHOD.
ENDCLASS.
