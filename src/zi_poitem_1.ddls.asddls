@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Basic View - Purchase Order Item'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_POITEM_1
  as select from zpoitem_1 as PO_Item
  association to parent ZI_PURCHASEORDER_1 as _PurchaseOrder 
    on $projection.PoID = _PurchaseOrder.PoID
{
  key po_id                                              as PoID,
  key item_id                                            as ItemID,
      material_id                                        as MaterialID,
      plant                                              as Plant,
      
      @Semantics.quantity.unitOfMeasure: 'UnitOfMeasure'
      quantity                                           as Quantity,
      unit_of_measure                                    as UnitOfMeasure,
      currency_code                                      as CurrencyCode,
      
      @Semantics.amount.currencyCode: 'CurrencyCode'
      unit_price                                         as UnitPrice,
      
      @Semantics.amount.currencyCode: 'CurrencyCode'
      net_value                                          as NetValue,
      delivery_date                                      as DeliveryDate,

      case 
        when net_value < 1000 then 'Low'
        when net_value < 10000 then 'Medium'
        else 'High'
      end                                                as ItemValueCategory,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      case
        when PO_Item.quantity > cast( 100 as abap.quan(13,3) )
        then cast( PO_Item.unit_price as abap.dec(15,2) ) * cast( 5 as abap.dec(5,2) ) / cast( 100 as abap.dec(5,2) )
        else cast( 0 as abap.dec(15,2) )
      end                                                as DiscountAmount,

      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at                                    as LastChangedAt,
      
      _PurchaseOrder
}
