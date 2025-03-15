INTERFACE zif_aur_test_config
  PUBLIC.

  "! Destination to run the test runner
  CONSTANTS aunit_destination TYPE string                          VALUE ``.

  "! Sender mail
  CONSTANTS mail_sender       TYPE cl_bcs_mail_message=>ty_address VALUE ``.

  "! Receiver mail
  CONSTANTS mail_receiver     TYPE cl_bcs_mail_message=>ty_address VALUE ``.
ENDINTERFACE.
