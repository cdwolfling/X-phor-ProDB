
/*
2026-03-26 JC: 参考vw_CPTestData， 用PIVOT， 将key/value的存储结果， 展示为多列的形式
select v.ProductModel, v.LotWafer as LotID_Wafer, v.Die_Location, v.Dev_ID, tray.LotWaferTrayKey, v.ChipSN
    , [UGC_CW], [UGC], [UEC], [UEC_Onchip], [CH01], [CH02], [CH03], [CH04], [Loss_range]
    , [ER_CH01], [ER_CH02], [ER_CH03], [ER_CH04], [PPI_CH01], [PPI_CH02], [PPI_CH03], [PPI_CH04], [HTU_CH01], [HTU_CH02], [HTU_CH03], [HTU_CH04]
    , [IMPD_CH01_OC], [OMPDM_CH01_OC], [OMPDM_CH02_OC], [OMPDM_CH03_OC], [OMPDM_CH04_OC], [OMPDS_CH01_OC], [OMPDS_CH02_OC], [OMPDS_CH03_OC], [OMPDS_CH04_OC]
    , [IMPD_CH01_C], [OMPDM_CH01_C], [OMPDM_CH02_C], [OMPDM_CH03_C], [OMPDM_CH04_C], [OMPDS_CH01_C], [OMPDS_CH02_C], [OMPDS_CH03_C], [OMPDS_CH04_C]
    , [IMPD_CH01_db], [OMPDM_CH01_db], [OMPDM_CH02_db], [OMPDM_CH03_db], [OMPDM_CH04_db], [OMPDS_CH01_db], [OMPDS_CH02_db], [OMPDS_CH03_db], [OMPDS_CH04_db]
    , [Onchip_loss_CH01_MPD], [Onchip_loss_CH02_MPD], [Onchip_loss_CH03_MPD], [Onchip_loss_CH04_MPD], [MPD_Loss_range]
    FROM [dbo].[vw_CPTestData_Coral3p1] v
    left join (
    select h.LotWafer,h.LotWaferTrayKey,c.ChipSN from dbo.TrayMapHeader h 
    join dbo.TrayMapCell c on h.TrayMapId=c.TrayMapId) tray on v.LotWafer=tray.LotWafer and v.ChipSN=tray.ChipSN
    where v.LotWafer='LN47753-W01'
    and v.isRecent=1
    ORDER BY v.LotWafer, Dev_ID, Die_Location

Change Log:
2026-04-08 JC: Initial.
*/
CREATE   VIEW [dbo].[vw_CPTestData_Coral3p1] AS
WITH S AS
(
select f.ProductModel, f.LotWafer, f.isRecent, f.FilePath, f.FileModifiedTime, f.CPTest_TrackOutTime
    , c.TestTime, c.Dev_ID, c.Die_Location, c.ChipSN, v.Val, pd.ParamName, f.Station
    from dbo.CPTest_File f
    LEFT JOIN dbo.CPTest_Chip c
        ON c.FileId = F.FileId
    LEFT JOIN dbo.CPTest_Value v
        ON v.ChipTestId = c.ChipTestId
    LEFT JOIN dbo.CPTest_ParamDef pd
        ON pd.ParamId = v.ParamId
    where f.ProductModel='Coral3p1'
)
SELECT ProductModel, LotWafer, isRecent, FilePath, FileModifiedTime, CPTest_TrackOutTime, TestTime, Dev_ID, Die_Location, ChipSN, Station
    , p.[UGC_CW], [UGC], [UEC], [UEC_Onchip], [CH01], [CH02], [CH03], [CH04], [Loss_range]
    , [ER_CH01], [ER_CH02], [ER_CH03], [ER_CH04], [PPI_CH01], [PPI_CH02], [PPI_CH03], [PPI_CH04], [HTU_CH01], [HTU_CH02], [HTU_CH03], [HTU_CH04]
    , [IMPD_CH01_OC], [OMPDM_CH01_OC], [OMPDM_CH02_OC], [OMPDM_CH03_OC], [OMPDM_CH04_OC], [OMPDS_CH01_OC], [OMPDS_CH02_OC], [OMPDS_CH03_OC], [OMPDS_CH04_OC]
    , [IMPD_CH01_C], [OMPDM_CH01_C], [OMPDM_CH02_C], [OMPDM_CH03_C], [OMPDM_CH04_C], [OMPDS_CH01_C], [OMPDS_CH02_C], [OMPDS_CH03_C], [OMPDS_CH04_C]
    , [IMPD_CH01_db], [OMPDM_CH01_db], [OMPDM_CH02_db], [OMPDM_CH03_db], [OMPDM_CH04_db], [OMPDS_CH01_db], [OMPDS_CH02_db], [OMPDS_CH03_db], [OMPDS_CH04_db]
    , [Onchip_loss_CH01_MPD], [Onchip_loss_CH02_MPD], [Onchip_loss_CH03_MPD], [Onchip_loss_CH04_MPD], [MPD_Loss_range]
    FROM S
    PIVOT
    (
        MAX(Val) FOR ParamName IN ([UGC_CW], [UGC], [UEC], [UEC_Onchip], [CH01], [CH02], [CH03], [CH04], [Loss_range]
        , [ER_CH01], [ER_CH02], [ER_CH03], [ER_CH04], [PPI_CH01], [PPI_CH02], [PPI_CH03], [PPI_CH04], [HTU_CH01], [HTU_CH02], [HTU_CH03], [HTU_CH04]
        , [IMPD_CH01_OC], [OMPDM_CH01_OC], [OMPDM_CH02_OC], [OMPDM_CH03_OC], [OMPDM_CH04_OC], [OMPDS_CH01_OC], [OMPDS_CH02_OC], [OMPDS_CH03_OC], [OMPDS_CH04_OC]
        , [IMPD_CH01_C], [OMPDM_CH01_C], [OMPDM_CH02_C], [OMPDM_CH03_C], [OMPDM_CH04_C], [OMPDS_CH01_C], [OMPDS_CH02_C], [OMPDS_CH03_C], [OMPDS_CH04_C]
        , [IMPD_CH01_db], [OMPDM_CH01_db], [OMPDM_CH02_db], [OMPDM_CH03_db], [OMPDM_CH04_db], [OMPDS_CH01_db], [OMPDS_CH02_db], [OMPDS_CH03_db], [OMPDS_CH04_db]
        , [Onchip_loss_CH01_MPD], [Onchip_loss_CH02_MPD], [Onchip_loss_CH03_MPD], [Onchip_loss_CH04_MPD], [MPD_Loss_range]
        )
    ) p