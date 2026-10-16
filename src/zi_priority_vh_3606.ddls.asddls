@EndUserText.label: 'Incident Priority Value Help'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Search.searchable: true

define view entity ZI_PRIORITY_VH_3606
  as select from zdt_priorit_3606
{
      @Search.defaultSearchElement: true
  key priority_code        as Priority,

      @Search.defaultSearchElement: true
      priority_description as PriorityDescription
}
