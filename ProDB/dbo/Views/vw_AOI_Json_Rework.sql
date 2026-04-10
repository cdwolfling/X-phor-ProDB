/*
==========================================================================
视图名称：vw_AOI_Json_Rework
业务用途：AOI_Json_Rework相关的文件名及文件内容
SELECT * FROM dbo.vw_AOI_Json_Rework v WHERE v.LotNo='LN40845'
==========================================================================
*/
CREATE VIEW [dbo].[vw_AOI_Json_Rework]
AS
SELECT j3.ProductModel, j3.LotNo, j3.Wafer, j3.TrayNo, j3.JsonPath, j3.FileModifiedTime
    , j3d.WaferID, j3d.LoadPos, j3d.chipRegPos, j3d.Name, j3d.TrayKey, j3d.TrayIndex, j3d.UnLoadPos, j3d.Bin, j3d.AOIResult, j3d.GAOIResult
    FROM dbo.AOI_Json_Rework j3
    JOIN dbo.AOI_Json_Rework_Data j3d ON j3.ID=j3d.jsonReworkId