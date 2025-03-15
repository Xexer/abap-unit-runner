INTERFACE zif_aur_job_log
  PUBLIC.

  "! Create application log and attach to job
  "! @parameter setting    | Settings for the run
  "! @parameter run_result | Result of the run
  METHODS create_and_attach_log
    IMPORTING setting    TYPE zif_aur_runner=>setting
              run_result TYPE zif_aur_runner=>run_result.
ENDINTERFACE.
