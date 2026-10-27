CLASS zcl_generate_po_data_1 DEFINITION
  PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_generate_po_data_1 IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DELETE FROM zpurchaseorder_1.
    DELETE FROM zpoitem_1.

    DATA: lt_header TYPE TABLE OF zpurchaseorder_1,
          lt_item   TYPE TABLE OF zpoitem_1.

    GET TIME STAMP FIELD DATA(lv_ts).
    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).

    lt_header = VALUE #(
      ( client = sy-mandt po_id = '1000000001' vendor_id = 'VEND01' purch_org = '1000' currency_code = 'EUR'
        total_amount = '15000.00' discount_pct = '5.00' status = 'O' po_date = lv_today delivery_date = lv_today
        created_by = sy-uname last_changed_at = lv_ts )
      ( client = sy-mandt po_id = '1000000002' vendor_id = 'VEND02' purch_org = '1000' currency_code = 'USD'
        total_amount = '500.00'   status = 'A' po_date = lv_today delivery_date = lv_today + 5
        created_by = sy-uname last_changed_at = lv_ts )
      ( client = sy-mandt po_id = '1000000003' vendor_id = 'VEND01' purch_org = '2000' currency_code = 'EUR'
        total_amount = '8200.00'  discount_pct = '2.50' status = 'B' po_date = lv_today delivery_date = lv_today + 15
        created_by = sy-uname last_changed_at = lv_ts )
      ( client = sy-mandt po_id = '1000000004' vendor_id = 'VEND03' purch_org = '1000' currency_code = 'USD'
        total_amount = '25000.00' status = 'X' po_date = lv_today delivery_date = lv_today + 45
        created_by = sy-uname last_changed_at = lv_ts )
      ( client = sy-mandt po_id = '1000000005' vendor_id = 'VEND02' purch_org = '2000' currency_code = 'EUR'
        total_amount = '1200.00'  discount_pct = '10.00' status = 'O' po_date = lv_today delivery_date = lv_today + 1
        created_by = sy-uname last_changed_at = lv_ts )
    ).

    lt_item = VALUE #(
      ( client = sy-mandt po_id = '1000000001' item_id = '00010' material_id = 'MAT-001' plant = '1000'
        quantity = '150.000' unit_of_measure = 'ST' currency_code = 'EUR' unit_price = '100.00' net_value = '15000.00' delivery_date = lv_today
        last_changed_at = lv_ts )
      ( client = sy-mandt po_id = '1000000002' item_id = '00010' material_id = 'MAT-002' plant = '1000'
        quantity = '10.000'  unit_of_measure = 'ST' currency_code = 'USD' unit_price = '50.00'  net_value = '500.00'   delivery_date = lv_today + 5
        last_changed_at = lv_ts )
      ( client = sy-mandt po_id = '1000000003' item_id = '00010' material_id = 'MAT-001' plant = '2000'
        quantity = '50.000'  unit_of_measure = 'ST' currency_code = 'EUR' unit_price = '100.00' net_value = '5000.00'  delivery_date = lv_today + 15
        last_changed_at = lv_ts )
      ( client = sy-mandt po_id = '1000000003' item_id = '00020' material_id = 'MAT-003' plant = '2000'
        quantity = '32.000'  unit_of_measure = 'ST' currency_code = 'EUR' unit_price = '100.00' net_value = '3200.00'  delivery_date = lv_today + 15
        last_changed_at = lv_ts )
      ( client = sy-mandt po_id = '1000000004' item_id = '00010' material_id = 'MAT-004' plant = '1000'
        quantity = '250.000' unit_of_measure = 'ST' currency_code = 'USD' unit_price = '100.00' net_value = '25000.00' delivery_date = lv_today + 45
        last_changed_at = lv_ts )
      ( client = sy-mandt po_id = '1000000005' item_id = '00010' material_id = 'MAT-002' plant = '2000'
        quantity = '12.000'  unit_of_measure = 'ST' currency_code = 'EUR' unit_price = '50.00'  net_value = '600.00'   delivery_date = lv_today + 1
        last_changed_at = lv_ts )
      ( client = sy-mandt po_id = '1000000005' item_id = '00020' material_id = 'MAT-003' plant = '2000'
        quantity = '4.000'   unit_of_measure = 'ST' currency_code = 'EUR' unit_price = '100.00' net_value = '400.00'   delivery_date = lv_today + 1
        last_changed_at = lv_ts )
      ( client = sy-mandt po_id = '1000000005' item_id = '00030' material_id = 'MAT-005' plant = '2000'
        quantity = '2.000'   unit_of_measure = 'ST' currency_code = 'EUR' unit_price = '100.00' net_value = '200.00'   delivery_date = lv_today + 1
        last_changed_at = lv_ts )
    ).

    INSERT zpurchaseorder_1 FROM TABLE @lt_header.
    INSERT zpoitem_1 FROM TABLE @lt_item.
    out->write( 'Sample data inserted successfully!' ).
  ENDMETHOD.
ENDCLASS.
