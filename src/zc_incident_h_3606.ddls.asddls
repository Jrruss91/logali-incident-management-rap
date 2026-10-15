@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View Entity - Projection History'
@Metadata.ignorePropagatedAnnotations: true
//@Search.searchable: true
@Metadata.allowExtensions: true
define view entity ZC_INCIDENT_H_3606
  as projection on ZI_INCIDENT_H_3606
{
  key HisUuid,
      IncUuid,
      HisId,
      PreviousStatus,
      NewStatus,
      Text,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangeBy,
      LocalLastChangeAt,
      LastChangeAt,
      /* Associations */
      _Incident : redirected to parent ZC_INCIDENT_3606
}
