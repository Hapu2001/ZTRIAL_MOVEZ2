@EndUserText.label: 'Consumption - Purchase Order Header'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Search.searchable: true
@ObjectModel.semanticKey: ['PoID']

define root view entity ZC_PURCHASEORDER_1
  provider contract transactional_query
  as projection on ZI_PURCHASEORDER_1
{
      @Search.defaultSearchElement: true
  key PoID,

      @Search.defaultSearchElement: true
      VendorID,

      PurchOrg,

      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CurrencyStdVH', element: 'Currency' }, useForValidation: true }]
      CurrencyCode,

      TotalAmount,
      TaxAmount,
      TotalWithTax,
      EffectiveDiscount,
      VendorDisplay,

      @ObjectModel.text.element: ['StatusText']
      Status,
      StatusText,

      PoDate,
      DeliveryDate,
      DaysToDelivery,
      UrgencyFlag,
      CreatedBy,
      LastChangedAt,

      /* Chuyển hướng quan hệ liên kết xuống Item */
      _Items : redirected to composition child ZC_POITEM_1
}
