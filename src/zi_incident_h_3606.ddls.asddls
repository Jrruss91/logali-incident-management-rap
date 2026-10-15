@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View Entity - History'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_INCIDENT_H_3606
  as select from zdt_inct_h_3606
  association to parent ZI_INCIDENT_3606 as _Incident on $projection.IncUuid = _Incident.IncUuid
{
  key his_uuid             as HisUuid,
      inc_uuid             as IncUuid,
      his_id               as HisId,
      previous_status      as PreviousStatus,
      new_status           as NewStatus,
      text                 as Text,
      @Semantics.user.createdBy: true
      local_created_by     as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at     as LocalCreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_change_by as LocalLastChangeBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_change_at as LocalLastChangeAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_change_at       as LastChangeAt,
      _Incident
}
