INTERFACE zif_aur_mail_html
  PUBLIC.

  TYPES: BEGIN OF format,
           column   TYPE i,
           positive TYPE abap_boolean,
           negative TYPE abap_boolean,
         END OF format.
  TYPES formats TYPE SORTED TABLE OF format WITH UNIQUE KEY column.

  CONSTANTS: BEGIN OF hex_color,
               positive     TYPE string VALUE `#d7fcda`,
               negative     TYPE string VALUE `#ffbaba`,
               table_back   TYPE string VALUE `#323236`,
               table_text   TYPE string VALUE `#ffffff`,
               table_border TYPE string VALUE `#cacaca`,
               head_color   TYPE string VALUE `#1c4c99`,
             END OF hex_color.

  "! Finish the HTML document and return
  "! @parameter result | HTML string
  METHODS finish_document
    RETURNING VALUE(result) TYPE string.

  "! Generate HTML table from generic table
  "! @parameter generic_data | Data for table
  "! @parameter formats      | Formatter for columns
  METHODS add_table
    IMPORTING generic_data TYPE REF TO data
              formats      TYPE zif_aur_mail_html=>formats OPTIONAL.

  "! Add big header to content (H1)
  "! @parameter text | Header text
  METHODS add_big_header
    IMPORTING !text TYPE clike.

  "! Add medium header to content (H3)
  "! @parameter text | Header text
  METHODS add_medium_header
    IMPORTING !text TYPE clike.

  "! Adds a break tag to the content
  "! @parameter times | Number of Breaks
  METHODS add_break
    IMPORTING !times TYPE i DEFAULT 1.
ENDINTERFACE.
