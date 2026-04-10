/*
Create by Jackiech on 2026-04-02
select v.ProductFamily, v.SpecVersion, v.EffectiveDate--, v.SpecRemark
    , v.ParameterKey, v.SpecValue
    from spec.vw_ProductFamilySpec v where v.ProductFamily='Coral3p1' and v.IsActive=1

*/
CREATE   VIEW spec.vw_ProductFamilySpec
AS
SELECT
    h.ProductFamilySpecId,
    h.ProductFamily,
    h.SpecVersion,
    h.IsActive,
    h.EffectiveDate,
    h.Remark AS SpecRemark,
    h.CreatedOn AS SpecCreatedOn,
    h.CreatedBy AS SpecCreatedBy,

    d.ProductFamilySpecDetailId,
    d.ParameterId,
    p.ParameterKey,
    p.ParameterName,
    p.IsEnabled AS ParameterIsEnabled,
    d.SpecValue
FROM spec.ProductFamilySpec h
INNER JOIN spec.ProductFamilySpecDetail d
    ON h.ProductFamilySpecId = d.ProductFamilySpecId
INNER JOIN spec.ParameterDef p
    ON d.ParameterId = p.ParameterId;