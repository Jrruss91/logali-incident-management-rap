@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Incident Root Entity'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_INCIDENT_3606
  as select from zdt_inct_3606
  composition [0..*] of ZI_INCIDENT_H_3606 as _History
{
  key inc_uuid             as IncUuid,
      incident_id          as IncidentId,
      title                as Title,
      description          as Description,
      status               as Status,
      priority             as Priority,
      create_date          as CreateDate,
      changed_date         as ChangedDate,
      @Semantics.user.createdBy: true
      local_created_by     as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at     as LocalCreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_change_by as LocalLastChangeBy,
      // Local ETag
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_change_at as LocalLastChangeAt,
      // Local ETag
      @Semantics.systemDateTime.lastChangedAt: true
      last_change_at       as LastChangeAt,
      //      _association_name // Make association public
      _History
}
