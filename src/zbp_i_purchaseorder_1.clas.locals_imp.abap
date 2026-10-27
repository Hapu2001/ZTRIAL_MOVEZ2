CLASS lhc_PurchaseOrder DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS setPoDate FOR DETERMINE ON MODIFY
      IMPORTING keys FOR PurchaseOrder~setPoDate.

    METHODS rejectPurchaseOrder FOR MODIFY
      IMPORTING keys FOR ACTION PurchaseOrder~rejectPurchaseOrder RESULT result.

ENDCLASS.

CLASS lhc_PurchaseOrder IMPLEMENTATION.

  METHOD setPoDate.
    READ ENTITIES OF zi_purchaseorder_1 IN LOCAL MODE
      ENTITY PurchaseOrder
      FIELDS ( PoDate )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_pos).

    MODIFY ENTITIES OF zi_purchaseorder_1 IN LOCAL MODE
      ENTITY PurchaseOrder
      UPDATE FIELDS ( PoDate )
      WITH VALUE #( FOR po IN lt_pos WHERE ( PoDate IS INITIAL )
                    ( %tky   = po-%tky
                      PoDate = cl_abap_context_info=>get_system_date( ) ) ).
  ENDMETHOD.

  METHOD rejectPurchaseOrder.
    DATA: lt_po_update TYPE TABLE FOR UPDATE zi_purchaseorder_1.

    " 1. Đọc thông tin PO hiện tại
    READ ENTITIES OF zi_purchaseorder_1 IN LOCAL MODE
      ENTITY PurchaseOrder
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_pos)
      FAILED failed.

    LOOP AT lt_pos ASSIGNING FIELD-SYMBOL(<fs_po>).
      " Lấy tham số truyền vào từ popup (%param)
      DATA(ls_param) = keys[ KEY id %tky = <fs_po>-%tky ]-%param.

      " 2. Kiểm tra nghiệp vụ: Bắt buộc phải có Reject Reason
      IF ls_param-RejectReason IS INITIAL.
        APPEND VALUE #( %tky = <fs_po>-%tky ) TO failed-purchaseorder.
        APPEND VALUE #( %tky = <fs_po>-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Vui lòng nhập lý do từ chối (Reject Reason)!' )
                      ) TO reported-purchaseorder.
        CONTINUE.
      ENDIF.

      " 3. Kiểm tra nếu PO đã bị Reject trước đó (Status = 'R')
      IF <fs_po>-Status = 'R'.
        APPEND VALUE #( %tky = <fs_po>-%tky ) TO failed-purchaseorder.
        APPEND VALUE #( %tky = <fs_po>-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Đơn hàng này đã bị từ chối từ trước!' )
                      ) TO reported-purchaseorder.
        CONTINUE.
      ENDIF.

      " 4. Cập nhật Status sang 'R' (Rejected)
      APPEND VALUE #( %tky              = <fs_po>-%tky
                      Status            = 'R'
                      %control-Status   = if_abap_behv=>mk-on ) TO lt_po_update.

      " Thông báo thành công
      APPEND VALUE #( %tky = <fs_po>-%tky
                      %msg = new_message_with_text(
                               severity = if_abap_behv_message=>severity-success
                               text     = |Đơn hàng { <fs_po>-PoID } đã bị từ chối.| )
                    ) TO reported-purchaseorder.
    ENDLOOP.

    " Thực hiện update vào DB
    IF lt_po_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_purchaseorder_1 IN LOCAL MODE
        ENTITY PurchaseOrder
        UPDATE FROM lt_po_update
        FAILED failed
        REPORTED reported.
    ENDIF.

    " 5. Đọc lại dữ liệu mới nhất để trả về [1] $self
    READ ENTITIES OF zi_purchaseorder_1 IN LOCAL MODE
      ENTITY PurchaseOrder
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_updated_pos).

    result = VALUE #( FOR po IN lt_updated_pos ( %tky   = po-%tky
                                                 %param = po ) ).
  ENDMETHOD.

ENDCLASS.


CLASS lhc_PoItem DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS CalculateTotalAmount FOR DETERMINE ON MODIFY
      IMPORTING keys FOR PoItem~CalculateTotalAmount.

ENDCLASS.

CLASS lhc_PoItem IMPLEMENTATION.

  METHOD CalculateTotalAmount.
    " 1. Đọc Header ID từ các Item bị thay đổi
    READ ENTITIES OF zi_purchaseorder_1 IN LOCAL MODE
      ENTITY PoItem BY \_PurchaseOrder
      FIELDS ( PoID )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers).

    SORT lt_headers BY PoID.
    DELETE ADJACENT DUPLICATES FROM lt_headers COMPARING PoID.
    CHECK lt_headers IS NOT INITIAL.

    " 2. Đọc NetValue của tất cả Items thuộc đơn hàng đó
    READ ENTITIES OF zi_purchaseorder_1 IN LOCAL MODE
      ENTITY PurchaseOrder BY \_Items
      FIELDS ( NetValue )
      WITH CORRESPONDING #( lt_headers )
      RESULT DATA(lt_items).

    " 3. Total Amount = SUM( NetValue )
    DATA lt_po_update TYPE TABLE FOR UPDATE zi_purchaseorder_1.

    LOOP AT lt_headers INTO DATA(ls_header).
      DATA(lv_total) = VALUE zpurchaseorder_1-total_amount( ).

      LOOP AT lt_items INTO DATA(ls_item) WHERE PoID = ls_header-PoID.
        lv_total = lv_total + ls_item-NetValue.
      ENDLOOP.

      APPEND VALUE #( %tky                  = ls_header-%tky
                      TotalAmount           = lv_total
                      %control-TotalAmount  = if_abap_behv=>mk-on ) TO lt_po_update.
    ENDLOOP.

    " 4. Cập nhật lại vào Header
    MODIFY ENTITIES OF zi_purchaseorder_1 IN LOCAL MODE
      ENTITY PurchaseOrder
      UPDATE FROM lt_po_update.
  ENDMETHOD.

ENDCLASS.
