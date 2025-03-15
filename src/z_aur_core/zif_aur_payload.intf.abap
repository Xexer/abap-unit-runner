INTERFACE zif_aur_payload
  PUBLIC.

  "! Creates XML payload for Unit Test start
  "! @parameter run_setting | Settings for creation
  "! @parameter result      | <p class="shorttext synchronized"></p>
  METHODS get_xml_payload
    IMPORTING run_setting   TYPE zif_aur_runner=>setting
    RETURNING VALUE(result) TYPE string.
ENDINTERFACE.
