@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Basic View - Purchase Order Header'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_PURCHASEORDER_1
  as select from zpurchaseorder_1 as PO
  composition [0..*] of ZI_POITEM_1 as _Items
{
  key po_id                                              as PoID,
      vendor_id                                          as VendorID,
      purch_org                                          as PurchOrg,
      currency_code                                      as CurrencyCode,
      
      @Semantics.amount.currencyCode: 'CurrencyCode'
      total_amount                                       as TotalAmount,

      /*
        TAI SAO PHAI CAST?
        Kieu abap.curr khong ho tro phep tinh phuc hop truc tiep voi integer literal
        va de bi loi integer division lam mat phan thap phan. 
        Cast sang abap.dec(15,2) giup dam bao do chinh xac so thuc co dinh.
      */
      @Semantics.amount.currencyCode: 'CurrencyCode'
      cast( PO.total_amount as abap.dec(15,2) )
        * cast( 10 as abap.dec(5,2) )
        / cast( 100 as abap.dec(5,2) )                   as TaxAmount,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      cast( PO.total_amount as abap.dec(15,2) ) +
      ( cast( PO.total_amount as abap.dec(15,2) )
        * cast( 10 as abap.dec(5,2) )
        / cast( 100 as abap.dec(5,2) ) )                 as TotalWithTax,

      -- Requirement: COALESCE discount_pct NULL -> 0
      coalesce( PO.discount_pct, cast( 0 as abap.dec(5,2) ) ) as EffectiveDiscount,

      -- Requirement: Concat purch_org va vendor_id
      concat_with_space( PO.purch_org, PO.vendor_id, 1 ) as VendorDisplay,

      status                                             as Status,
      -- Requirement: CASE StatusText
      case status
        when 'O' then 'Open'
        when 'A' then 'Approved'
        when 'X' then 'Cancelled'
        when 'B' then 'Blocked'
        else 'Unknown'
      end                                                as StatusText,

      po_date                                            as PoDate,
      delivery_date                                      as DeliveryDate,

      -- Requirement: dats_days_between
      dats_days_between($session.system_date, delivery_date) as DaysToDelivery,

      -- Requirement: CASE UrgencyFlag
      case
        when dats_days_between($session.system_date, delivery_date) < 0  then 'Overdue'
        when dats_days_between($session.system_date, delivery_date) <= 7 then 'Urgent'
        when dats_days_between($session.system_date, delivery_date) <= 30 then 'Normal'
        else 'Low'
      end                                                as UrgencyFlag,

      @Semantics.user.createdBy: true
      created_by                                         as CreatedBy,

      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at                                    as LastChangedAt,

      _Items
}
