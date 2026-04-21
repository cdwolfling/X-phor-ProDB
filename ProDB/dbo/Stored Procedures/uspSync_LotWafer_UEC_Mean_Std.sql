
/*
-- =============================================
-- Author:		Jackie Chen
-- Create date: 2026-04-08
-- Description:	对 dbo.CPTest_File 中的LotWafer, 计算并记录其UEC_Mean_Std值
-- Notes:
select * from dbo.LotWafer_UEC_Mean_Std d where d.FinishDieParameter=0

Change Log:
2026-04-21 JC: Changed the lookback date to 2025-01-01
2026-04-20 JC: Changed the lookback period from 40 days to 120 days.
2026-04-16 JC: set u.FinishDieParameter = 0, if update happened
-- =============================================
*/
CREATE   PROCEDURE [dbo].[uspSync_LotWafer_UEC_Mean_Std]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Now DATETIME = GETDATE();
    /* 1. insert */
    INSERT INTO dbo.LotWafer_UEC_Mean_Std
    (
        LotWafer,
        CPFileTime,
        Mean,
        Std
    )
    SELECT
        cp.LotWafer,
        cp.FileModifiedTime,
        ms.mean,
        ms.std
    FROM dbo.CPTest_File cp
    LEFT JOIN dbo.LotWafer_UEC_Mean_Std u
        ON cp.LotWafer = u.LotWafer
       AND cp.FileModifiedTime = u.CPFileTime
    OUTER APPLY dbo.ufn_GetUEC_Mean_Std(cp.LotWafer) ms
    WHERE cp.FileModifiedTime >= '2025-01-01'
      AND cp.isRecent = 1
      AND cp.FileModifiedTime <= DATEADD(MINUTE, -5, @Now)
      AND u.LotWafer IS NULL;

    /* 2. update */
    IF OBJECT_ID('tempdb..#ToUpdate') IS NOT NULL DROP TABLE #ToUpdate;
    CREATE TABLE #ToUpdate
    (
        LotWafer     VARCHAR(50)   NOT NULL,
        CPFileTime   DATETIME      NOT NULL,
        MeanValue    FLOAT         NULL,
        StdValue     FLOAT         NULL
    );
    INSERT INTO #ToUpdate
    (
        LotWafer,
        CPFileTime,
        MeanValue,
        StdValue
    )
    SELECT
        cp.LotWafer,
        cp.FileModifiedTime,
        ms.mean,
        ms.std
    FROM dbo.CPTest_File cp
    JOIN dbo.LotWafer_UEC_Mean_Std u ON cp.LotWafer = u.LotWafer
    OUTER APPLY dbo.ufn_GetUEC_Mean_Std(cp.LotWafer) ms
    WHERE cp.isRecent = 1
      AND cp.FileModifiedTime <> u.CPFileTime;

    UPDATE u
       SET u.CPFileTime = t.CPFileTime,
           u.Mean       = t.MeanValue,
           u.Std        = t.StdValue,
           u.Udt        = @Now,
           u.FinishDieParameter        = 0
    FROM dbo.LotWafer_UEC_Mean_Std u
    JOIN #ToUpdate t
        ON u.LotWafer = t.LotWafer;
END;