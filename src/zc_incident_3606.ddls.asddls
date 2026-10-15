@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View Entity - Projection Incident'
@Metadata.ignorePropagatedAnnotations: true
//@Search.searchable: true
@Metadata.allowExtensions: true
define root view entity ZC_INCIDENT_3606
  provider contract transactional_query
  as projection on ZI_INCIDENT_3606
{
  key IncUuid,
      IncidentId,
      Title,
      Description,
      Status,
      Priority,
      CreateDate,
      ChangedDate,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangeBy,
      LocalLastChangeAt,
      LastChangeAt,
      /* Associations */
      _History : redirected to composition child ZC_INCIDENT_H_3606
}
