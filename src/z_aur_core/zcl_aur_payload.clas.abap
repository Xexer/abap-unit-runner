CLASS zcl_aur_payload DEFINITION
  PUBLIC FINAL
  CREATE PRIVATE
  GLOBAL FRIENDS zcl_aur_core_factory.

  PUBLIC SECTION.
    INTERFACES zif_aur_payload.

  PRIVATE SECTION.
    CONSTANTS namespace_aunit TYPE string VALUE `http://www.sap.com/adt/api/aunit`.
    CONSTANTS namespace_osl   TYPE string VALUE `http://www.sap.com/api/osl`.
    CONSTANTS namespace_xsi   TYPE string VALUE `http://www.w3.org/2001/XMLSchema-instance`.

    DATA writer      TYPE REF TO if_sxml_writer.
    DATA run_setting TYPE zif_aur_runner=>setting.

    "! Convert ABAP_BOOLEAN to XML Bool
    "! @parameter boolean | ABAP Bool
    "! @parameter result  | XML Bool
    METHODS abool_to_bool
      IMPORTING boolean       TYPE abap_boolean
      RETURNING VALUE(result) TYPE string.

    "! Open run tag
    METHODS open_run.

    "! Close a node
    METHODS close_node.

    "! Set options
    METHODS set_options.

    "! Set measurements
    METHODS set_measurements.

    "! Set scope
    METHODS set_scope.

    "! Set rsik level
    METHODS set_risk_level.

    "! Set duration
    METHODS set_duration.

    " Set all objects for test
    METHODS set_objects.

    "! Add packages
    METHODS add_packages.

    "! Add objects
    METHODS add_objects.

    "! Add a package
    "! @parameter package | Name of the package
    METHODS add_package
      IMPORTING !package TYPE clike.

    "! Add a class
    "! @parameter class | Name of the class
    METHODS add_class
      IMPORTING !class TYPE clike.
ENDCLASS.


CLASS zcl_aur_payload IMPLEMENTATION.
  METHOD zif_aur_payload~get_xml_payload.
    me->run_setting = run_setting.

    DATA(string_writer) = cl_sxml_string_writer=>create( ).
    me->writer = CAST if_sxml_writer( string_writer ).

    open_run( ).
    set_options( ).
    set_objects( ).
    close_node( ).

    DATA(binary) = string_writer->get_output( ).
    DATA(content) = xco_cp=>xstring( binary )->as_string( xco_cp_character=>code_page->utf_8 )->value.

    RETURN |<?xml version="1.0" encoding="UTF-8"?>{ content }|.
  ENDMETHOD.


  METHOD abool_to_bool.
    IF boolean = abap_true.
      RETURN `true`.
    ELSE.
      RETURN `false`.
    ENDIF.
  ENDMETHOD.


  METHOD open_run.
    DATA(open_node) = writer->new_open_element( name   = `run`
                                                nsuri  = namespace_aunit
                                                prefix = `aunit` ).
    open_node->set_attribute( name  = `title`
                              value = run_setting-title ).
    open_node->set_attribute( name  = `context`
                              value = `AIE Integration Test` ).
    writer->write_node( open_node ).
  ENDMETHOD.


  METHOD close_node.
    writer->write_node( writer->new_close_element( ) ).
  ENDMETHOD.


  METHOD set_options.
    DATA(open_node) = writer->new_open_element( name   = `options`
                                                nsuri  = namespace_aunit
                                                prefix = `aunit` ).
    writer->write_node( open_node ).

    set_measurements( ).
    set_scope( ).
    set_risk_level( ).
    set_duration( ).

    close_node( ).
  ENDMETHOD.


  METHOD set_measurements.
    DATA(open_node) = writer->new_open_element( name   = `measurements`
                                                nsuri  = namespace_aunit
                                                prefix = `aunit` ).

    DATA(measurement) = COND #( WHEN run_setting-measurement IS NOT INITIAL THEN run_setting-measurement ELSE `none` ).

    " Attribute seems not to work atm
    measurement = `none`.

    open_node->set_attribute( name  = `type`
                              value = measurement ).
    writer->write_node( open_node ).

    close_node( ).
  ENDMETHOD.


  METHOD set_scope.
    DATA(open_node) = writer->new_open_element( name   = `scope`
                                                nsuri  = namespace_aunit
                                                prefix = `aunit` ).
    open_node->set_attribute( name  = `ownTests`
                              value = abool_to_bool( run_setting-scope_own ) ).
    open_node->set_attribute( name  = `foreignTests`
                              value = abool_to_bool( run_setting-scope_foreign ) ).
    writer->write_node( open_node ).

    close_node( ).
  ENDMETHOD.


  METHOD set_risk_level.
    DATA(open_node) = writer->new_open_element( name   = `riskLevel`
                                                nsuri  = namespace_aunit
                                                prefix = `aunit` ).
    open_node->set_attribute( name  = `harmless`
                              value = abool_to_bool( run_setting-risklevel_harmless ) ).
    open_node->set_attribute( name  = `dangerous`
                              value = abool_to_bool( run_setting-risklevel_dangerous ) ).
    open_node->set_attribute( name  = `critical`
                              value = abool_to_bool( run_setting-risklevel_critical ) ).
    writer->write_node( open_node ).

    close_node( ).
  ENDMETHOD.


  METHOD set_duration.
    DATA(open_node) = writer->new_open_element( name   = `duration`
                                                nsuri  = namespace_aunit
                                                prefix = `aunit` ).
    open_node->set_attribute( name  = `short`
                              value = abool_to_bool( run_setting-duration_short ) ).
    open_node->set_attribute( name  = `medium`
                              value = abool_to_bool( run_setting-duration_medium ) ).
    open_node->set_attribute( name  = `long`
                              value = abool_to_bool( run_setting-duration_long ) ).
    writer->write_node( open_node ).

    close_node( ).
  ENDMETHOD.


  METHOD set_objects.
    DATA(open_node) = writer->new_open_element( name   = `objectSet`
                                                nsuri  = namespace_osl
                                                prefix = `osl` ).
    open_node->set_attribute( name   = `type`
                              nsuri  = namespace_xsi
                              prefix = `xsi`
                              value  = `unionSet` ).
    writer->write_node( open_node ).

    add_packages( ).
    add_objects( ).

    close_node( ).
  ENDMETHOD.


  METHOD add_packages.
    DATA(open_node) = writer->new_open_element( name   = `set`
                                                nsuri  = namespace_osl
                                                prefix = `osl` ).
    open_node->set_attribute( name   = `type`
                              nsuri  = namespace_xsi
                              prefix = `xsi`
                              value  = `osl:packageSet` ).
    writer->write_node( open_node ).

    LOOP AT run_setting-packages INTO DATA(package).
      add_package( package ).
    ENDLOOP.

    close_node( ).
  ENDMETHOD.


  METHOD add_package.
    DATA(open_node) = writer->new_open_element( name   = `package`
                                                nsuri  = namespace_osl
                                                prefix = `osl` ).
    open_node->set_attribute( name  = `includeSubpackages`
                              value = `true` ).
    open_node->set_attribute( name  = `name`
                              value = CONV #( package ) ).
    writer->write_node( open_node ).

    close_node( ).
  ENDMETHOD.


  METHOD add_objects.
    DATA(open_node) = writer->new_open_element( name   = `set`
                                                nsuri  = namespace_osl
                                                prefix = `osl` ).
    open_node->set_attribute( name   = `type`
                              nsuri  = namespace_xsi
                              prefix = `xsi`
                              value  = `osl:flatObjectSet` ).
    writer->write_node( open_node ).

    LOOP AT run_setting-classes INTO DATA(class).
      add_class( class ).
    ENDLOOP.

    close_node( ).
  ENDMETHOD.


  METHOD add_class.
    DATA(open_node) = writer->new_open_element( name   = `object`
                                                nsuri  = namespace_osl
                                                prefix = `osl` ).
    open_node->set_attribute( name  = `name`
                              value = CONV #( class ) ).
    open_node->set_attribute( name  = `type`
                              value = `CLAS` ).
    writer->write_node( open_node ).

    close_node( ).
  ENDMETHOD.
ENDCLASS.
