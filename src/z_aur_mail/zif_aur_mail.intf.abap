INTERFACE zif_aur_mail
  PUBLIC.

  TYPES: BEGIN OF mail_result,
           success       TYPE abap_boolean,
           error_message TYPE string,
         END OF mail_result.

  TYPES: BEGIN OF general_part,
           title          TYPE string,
           system         TYPE string,
           client         TYPE string,
           execution_user TYPE string,
           time           TYPE string,
           timestamp      TYPE string,
           failures       TYPE string,
           errors         TYPE string,
           skipped        TYPE string,
           asserts        TYPE string,
           tests          TYPE string,
         END OF general_part.
  TYPES general_parts TYPE STANDARD TABLE OF general_part WITH EMPTY KEY.

  TYPES: BEGIN OF object_part,
           tests     TYPE string,
           failures  TYPE string,
           errors    TYPE string,
           skipped   TYPE string,
           asserts   TYPE string,
           timestamp TYPE string,
           time      TYPE string,
         END OF object_part.
  TYPES object_parts TYPE STANDARD TABLE OF object_part WITH EMPTY KEY.

  TYPES: BEGIN OF method_part,
           name    TYPE string,
           time    TYPE string,
           asserts TYPE string,
         END OF method_part.
  TYPES method_parts TYPE STANDARD TABLE OF method_part WITH EMPTY KEY.

  TYPES: BEGIN OF format,
           column   TYPE i,
           positive TYPE abap_boolean,
           negative TYPE abap_boolean,
         END OF format.
  TYPES formats TYPE SORTED TABLE OF format WITH UNIQUE KEY column.

  CONSTANTS: BEGIN OF hex_color,
               positive   TYPE string VALUE `#98fa91`,
               negative   TYPE string VALUE `#ff6363`,
               table_back TYPE string VALUE `#222224`,
               table_text TYPE string VALUE `#ffffff`,
             END OF hex_color.

  "! Send the result as E-Mail
  "! @parameter setting    | Settings for the run
  "! @parameter run_result | Result of the run
  "! @parameter result     | Result of the mail process
  METHODS send
    IMPORTING setting       TYPE zif_aur_runner=>setting
              run_result    TYPE zif_aur_runner=>run_result
    RETURNING VALUE(result) TYPE mail_result.
ENDINTERFACE.
