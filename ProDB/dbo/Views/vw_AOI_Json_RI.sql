/*
==========================================================================
视图名称：vw_AOI_Json_RI
业务用途：AOI_Json_RI相关的文件名及文件内容
SELECT * FROM dbo.vw_AOI_Json_RI v WHERE v.LotNo='LN40845' and v.Wafer='W10'
==========================================================================
*/
CREATE VIEW [dbo].[vw_AOI_Json_RI]
AS
SELECT j1.ProductModel, j1.LotNo, j1.Wafer, j1.TrayNo, j1.JsonPath, j1.FileModifiedTime
    , j1d.BinInfo, j1d.ChipType, j1d.GChipType, j1d.ColPos, j1d.GImagePath, j1d.GImagePath_2, j1d.Name, j1d.RowPos, j1d.WaferInfo, j1d.YImagePath, j1d.YImagePath_2, j1d.GName, j1d.ImageReaded, j1d.GImageReaded
    FROM dbo.AOI_Json_RI j1
    JOIN dbo.AOI_Json_RI_Data j1d ON j1.ID=j1d.jsonRiId