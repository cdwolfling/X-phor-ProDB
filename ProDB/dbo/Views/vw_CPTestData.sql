


/*
2026-01-26 JC: 用PIVOT， 将key/value的存储结果， 展示为多列的形式
select * from [dbo].[vw_CPTestData] v
    where v.LotWafer='LN26944-W22'
    ORDER BY LotWafer, Dev_ID, Die_Location
select * from [dbo].[vw_CPTestData] v
    where v.LotWafer='LN45037-W01'
    ORDER BY LotWafer, Dev_ID, Die_Location

Change Log:
2026-04-21 JC: Add Onchip_MPD_CH01~Onchip_MPD_CH08
2026-04-17 JC: Add [IMPD_CH03_C],[IMPD_CH04_C]
2026-04-09 JC: Add Loss_range, PPI_CH01~PPI_CH08, MPD_Loss_range, OMPDM_CH01_db~OMPDM_CH08_db, OMPDS_CH01_db~OMPDS_CH08_db
2026-02-14 JC: Add HTU_CH01~HTU_CH08
2026-02-14 JC: Add new 18 output
2026-02-06 JC: Add new 1 output
2026-02-02 JC: output ER_CH01~ER_CH08
2026-01-27 JC: output TestTime, CPTest_TrackOutTime
2026-01-27 JC: remove where in S; output ProductModel, Station
2026-01-27 JC: Add output FileModifiedTime, Onchip_loss_CH01_MPD~Onchip_loss_CH08_MPD
*/
CREATE VIEW [dbo].[vw_CPTestData] AS
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
    --WHERE 1=1
    --and (pd.ParamName IN ('UGC_CW','UGC','UEC','UEC_Onchip','CH01','CH02','CH03','CH04','CH05','CH06','CH07','CH08'
    --    ,'Onchip_loss_CH01_MPD','Onchip_loss_CH02_MPD','Onchip_loss_CH03_MPD','Onchip_loss_CH04_MPD','Onchip_loss_CH05_MPD','Onchip_loss_CH06_MPD','Onchip_loss_CH07_MPD','Onchip_loss_CH08_MPD'
    --    ) OR pd.ParamName IS NULL
    --)
)
SELECT ProductModel, LotWafer, isRecent, FilePath, FileModifiedTime, CPTest_TrackOutTime, TestTime, Dev_ID, Die_Location, ChipSN, Station
    , p.[UGC_CW], p.[UGC], p.[UEC], p.[UEC_Onchip]
    , p.[CH01], p.[CH02], p.[CH03], p.[CH04], p.[CH05], p.[CH06], p.[CH07], p.[CH08]
    , p.[Onchip_loss_CH01_MPD], p.[Onchip_loss_CH02_MPD], p.[Onchip_loss_CH03_MPD], p.[Onchip_loss_CH04_MPD], p.[Onchip_loss_CH05_MPD], p.[Onchip_loss_CH06_MPD], p.[Onchip_loss_CH07_MPD], p.[Onchip_loss_CH08_MPD]
    , p.[ER_CH01], p.[ER_CH02], p.[ER_CH03], p.[ER_CH04], p.[ER_CH05], p.[ER_CH06], p.[ER_CH07], p.[ER_CH08]
    , Range_onchip_loss_mpd
    , p.[IMPD_CH01_C], p.[IMPD_CH02_C], p.[IMPD_CH03_C], p.[IMPD_CH04_C]
    , p.[OMPDM_CH01_C], p.[OMPDM_CH02_C], p.[OMPDM_CH03_C], p.[OMPDM_CH04_C], p.[OMPDM_CH05_C], p.[OMPDM_CH06_C], p.[OMPDM_CH07_C], p.[OMPDM_CH08_C], p.[OMPDS_CH01_C], p.[OMPDS_CH02_C], p.[OMPDS_CH03_C], p.[OMPDS_CH04_C], p.[OMPDS_CH05_C], p.[OMPDS_CH06_C], p.[OMPDS_CH07_C], p.[OMPDS_CH08_C]
    , p.[HTU_CH01], p.[HTU_CH02], p.[HTU_CH03], p.[HTU_CH04], p.[HTU_CH05], p.[HTU_CH06], p.[HTU_CH07], p.[HTU_CH08]
    -- 2026-04-09
    , p.Loss_range, p.[PPI_CH01], p.[PPI_CH02], p.[PPI_CH03], p.[PPI_CH04], p.[PPI_CH05], p.[PPI_CH06], p.[PPI_CH07], p.[PPI_CH08]
    , p.MPD_Loss_range
    , p.[OMPDM_CH01_db], p.[OMPDM_CH02_db], p.[OMPDM_CH03_db], p.[OMPDM_CH04_db], p.[OMPDM_CH05_db], p.[OMPDM_CH06_db], p.[OMPDM_CH07_db], p.[OMPDM_CH08_db]
    , p.[OMPDS_CH01_db], p.[OMPDS_CH02_db], p.[OMPDS_CH03_db], p.[OMPDS_CH04_db], p.[OMPDS_CH05_db], p.[OMPDS_CH06_db], p.[OMPDS_CH07_db], p.[OMPDS_CH08_db]
    , p.[Onchip_MPD_CH01], p.[Onchip_MPD_CH02], p.[Onchip_MPD_CH03], p.[Onchip_MPD_CH04], p.[Onchip_MPD_CH05], p.[Onchip_MPD_CH06], p.[Onchip_MPD_CH07], p.[Onchip_MPD_CH08]
    FROM S
    PIVOT
    (
        MAX(Val) FOR ParamName IN ([UGC_CW],[UGC],[UEC],[UEC_Onchip],[CH01],[CH02],[CH03],[CH04],[CH05],[CH06],[CH07],[CH08]
        ,[Onchip_loss_CH01_MPD],[Onchip_loss_CH02_MPD],[Onchip_loss_CH03_MPD],[Onchip_loss_CH04_MPD],[Onchip_loss_CH05_MPD],[Onchip_loss_CH06_MPD],[Onchip_loss_CH07_MPD],[Onchip_loss_CH08_MPD]
        ,[ER_CH01],[ER_CH02],[ER_CH03],[ER_CH04],[ER_CH05],[ER_CH06],[ER_CH07],[ER_CH08]
        ,Range_onchip_loss_mpd
        ,[IMPD_CH01_C],[IMPD_CH02_C],[IMPD_CH03_C],[IMPD_CH04_C]
        ,[OMPDM_CH01_C],[OMPDM_CH02_C],[OMPDM_CH03_C],[OMPDM_CH04_C],[OMPDM_CH05_C],[OMPDM_CH06_C],[OMPDM_CH07_C],[OMPDM_CH08_C],[OMPDS_CH01_C],[OMPDS_CH02_C],[OMPDS_CH03_C],[OMPDS_CH04_C],[OMPDS_CH05_C],[OMPDS_CH06_C],[OMPDS_CH07_C],[OMPDS_CH08_C]
        ,[HTU_CH01],[HTU_CH02],[HTU_CH03],[HTU_CH04],[HTU_CH05],[HTU_CH06],[HTU_CH07],[HTU_CH08]
        ,Loss_range,[PPI_CH01],[PPI_CH02],[PPI_CH03],[PPI_CH04],[PPI_CH05],[PPI_CH06],[PPI_CH07],[PPI_CH08]
        ,MPD_Loss_range
        ,[OMPDM_CH01_db],[OMPDM_CH02_db],[OMPDM_CH03_db],[OMPDM_CH04_db],[OMPDM_CH05_db],[OMPDM_CH06_db],[OMPDM_CH07_db],[OMPDM_CH08_db]
        ,[OMPDS_CH01_db],[OMPDS_CH02_db],[OMPDS_CH03_db],[OMPDS_CH04_db],[OMPDS_CH05_db],[OMPDS_CH06_db],[OMPDS_CH07_db],[OMPDS_CH08_db]
        , [Onchip_MPD_CH01], [Onchip_MPD_CH02], [Onchip_MPD_CH03], [Onchip_MPD_CH04], [Onchip_MPD_CH05], [Onchip_MPD_CH06], [Onchip_MPD_CH07], [Onchip_MPD_CH08]
        )
    ) p