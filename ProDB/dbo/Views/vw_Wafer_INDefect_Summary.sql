

/*
==========================================================================
视图名称：vw_Wafer_INDefect_Summary
业务用途：用于按Wafer统计目检不良数量
SELECT * FROM dbo.vw_Wafer_INDefect_Summary

Change Log:
==========================================================================
*/
CREATE VIEW [dbo].[vw_Wafer_INDefect_Summary]
AS
select d.LotWafer,p.DefectAreaCode, p.DefectTypeCode,count(1) as DefectQty
    from dbo.Die d
    join dbo.Die_AOIPicked p on d.DieID=p.DieID
    group by d.LotWafer,p.DefectAreaCode, p.DefectTypeCode