@EndUserText.label: 'Parameter for Reject Purchase Order'
define root abstract entity ZI_PO_REJECT_PARAM_1
{
  @EndUserText.label: 'Reject Reason'
  RejectReason : abap.char(250);

  @EndUserText.label: 'Rejected By'
  RejectedBy   : abap.char(12);
}
