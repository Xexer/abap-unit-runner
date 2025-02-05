INTERFACE zif_aur_parser
  PUBLIC.

  "! Parse ABAP Unit Run (Status)
  "! @parameter to_parse | XML String for Parsing
  "! @parameter result   | Status of the ABAP Unit Run
  METHODS parse_aunit_run
    IMPORTING to_parse      TYPE string
    RETURNING VALUE(result) TYPE zif_aur_runner=>aunit_run.

  "! Parse ABAP Unit Results
  "! @parameter to_parse | XML String for Parsing
  "! @parameter result   | Result of the ABAP Unit Run
  METHODS parse_aunit_result
    IMPORTING to_parse      TYPE string
    RETURNING VALUE(result) TYPE zif_aur_runner=>aunit_result.
ENDINTERFACE.
