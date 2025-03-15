CLASS zcl_aur_job_factory DEFINITION
  PUBLIC ABSTRACT FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    "! Craete Job Log object
    "! @parameter result | Instance for Log
    CLASS-METHODS create_job_log
      RETURNING VALUE(result) TYPE REF TO zif_aur_job_log.
ENDCLASS.


CLASS zcl_aur_job_factory IMPLEMENTATION.
  METHOD create_job_log.
    RETURN NEW zcl_aur_job_log( ).
  ENDMETHOD.
ENDCLASS.
