/*
==========================================================================
视图名称：vw_AOI_Json_ST
业务用途：AOI_Json_ST相关的文件名及文件内容
SELECT * FROM dbo.vw_AOI_Json_ST v WHERE v.LotNo='LN40845'
==========================================================================
*/
CREATE VIEW [dbo].[vw_AOI_Json_ST]
AS
SELECT j1.ProductModel, j1.LotNo, j1.Wafer, j1.TrayNo, j1.JsonPath, j1.FileModifiedTime
    , j1d.WaferID, j1d.LoadPos, j1d.Name, j1d.TrayKey, j1d.TrayIndex, j1d.UnLoadPos, j1d.Bin, j1d.AOIResult, j1d.GAOIResult
    FROM dbo.AOI_Json_ST j1
    JOIN dbo.AOI_Json_ST_Data j1d ON j1.ID=j1d.jsonSTId