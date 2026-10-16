@EndUserText.label: 'Incident Status Value Help'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Search.searchable: true

define view entity ZI_STATUS_VH_3606
  as select from zdt_status_3606
{
      @Search.defaultSearchElement: true
  key status_code        as Status,

      @Search.defaultSearchElement: true
      status_description as StatusDescription
}
