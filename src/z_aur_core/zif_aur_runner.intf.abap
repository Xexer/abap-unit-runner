INTERFACE zif_aur_runner
  PUBLIC.

  TYPES: BEGIN OF aunit_object,
           name TYPE string,
           type TYPE string,
         END OF aunit_object.
  TYPES aunit_objects TYPE STANDARD TABLE OF aunit_object WITH EMPTY KEY.

  TYPES: BEGIN OF setting,
           cloud_destination      TYPE string,
           communication_scenario TYPE if_com_management=>ty_cscn_id,
           wait_in_seconds        TYPE i,
           wait_cycles_for_result TYPE i,
           title                  TYPE string,
           scope_own              TYPE abap_boolean,
           scope_foreign          TYPE abap_boolean,
           risklevel_harmless     TYPE abap_boolean,
           risklevel_dangerous    TYPE abap_boolean,
           risklevel_critical     TYPE abap_boolean,
           duration_short         TYPE abap_boolean,
           duration_medium        TYPE abap_boolean,
           duration_long          TYPE abap_boolean,
           objects                TYPE aunit_objects,
         END OF setting.

  TYPES: BEGIN OF aunit_run,
           title               TYPE string,
           context             TYPE string,
           progress_status     TYPE string,
           progress_percentage TYPE i,
           execution_user      TYPE string,
           start               TYPE string,
           end                 TYPE string,
           result_link         TYPE string,
         END OF aunit_run.

  TYPES: BEGIN OF aunit_method,
           classname TYPE string,
           name      TYPE string,
           time      TYPE p LENGTH 16 DECIMALS 3,
           asserts   TYPE i,
         END OF aunit_method.
  TYPES aunit_methods TYPE STANDARD TABLE OF aunit_method WITH EMPTY KEY.

  TYPES: BEGIN OF aunit_test,
           name         TYPE string,
           tests        TYPE i,
           failures     TYPE i,
           errors       TYPE i,
           skipped      TYPE i,
           asserts      TYPE i,
           package      TYPE string,
           timestamp    TYPE string,
           time         TYPE p LENGTH 16 DECIMALS 3,
           hostname     TYPE string,
           test_methods TYPE aunit_methods,
         END OF aunit_test.
  TYPES aunit_tests TYPE STANDARD TABLE OF aunit_test WITH EMPTY KEY.

  TYPES: BEGIN OF aunit_result,
           title          TYPE string,
           system         TYPE string,
           client         TYPE string,
           execution_user TYPE string,
           time           TYPE p LENGTH 16 DECIMALS 3,
           timestamp      TYPE string,
           failures       TYPE i,
           errors         TYPE i,
           skipped        TYPE i,
           asserts        TYPE i,
           tests          TYPE i,
           test_details   TYPE aunit_tests,
         END OF aunit_result.

  TYPES: BEGIN OF run_result,
           success       TYPE abap_bool,
           error_message TYPE string,
           aunit_result  TYPE aunit_result,
         END OF run_result.

  CONSTANTS: BEGIN OF content_type,
               start  TYPE string VALUE `application/vnd.sap.adt.api.abapunit.run.v1+xml`,
               check  TYPE string VALUE `application/vnd.sap.adt.api.abapunit.run-status.v1+xml`,
               result TYPE string VALUE `application/vnd.sap.adt.api.junit.run-result.v1+xml`,
             END OF content_type.

  CONSTANTS: BEGIN OF endpoints,
               runs    TYPE string VALUE `/sap/bc/adt/api/abapunit/runs`,
               results TYPE string VALUE `/sap/bc/adt/api/abapunit/results`,
             END OF endpoints.

  CONSTANTS: BEGIN OF run_status,
               running  TYPE string VALUE `RUNNING`,
               finished TYPE string VALUE `FINISHED`,
             END OF run_status.

  "! Execute the ABAP Unit Run for the objects and settings
  "! @parameter setting | Settings
  "! @parameter result  | Result for the run
  METHODS execute
    IMPORTING setting       TYPE setting
    RETURNING VALUE(result) TYPE run_result.
ENDINTERFACE.
