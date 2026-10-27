@EndUserText.label: 'Consumption - Purchase Order Item'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true

define view entity ZC_POITEM_1
  as projection on ZI_POITEM_1
{
  key PoID,
  key ItemID,
      MaterialID,
      Plant,
      Quantity,
      UnitOfMeasure,
      CurrencyCode,
      UnitPrice,
      NetValue,
      DeliveryDate,
      ItemValueCategory,
      DiscountAmount,
      LastChangedAt,

      /* Chuyển hướng quan hệ liên kết ngược về Header */
      _PurchaseOrder : redirected to parent ZC_PURCHASEORDER_1
}
