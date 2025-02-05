INTERFACE zif_aur_mail
  PUBLIC.

  "! Send the result as E-Mail
  "! @parameter run_result | Result of the run
  METHODS send
    IMPORTING run_result TYPE zif_aur_runner=>run_result.
ENDINTERFACE.
