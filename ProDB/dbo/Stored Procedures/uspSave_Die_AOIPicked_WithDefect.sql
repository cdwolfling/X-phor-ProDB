/*
-- =============================================
-- Author:		Jackie Chen
-- Create date: 2026-03-12
-- Description:	保存Die的目检不良信息, 1-HH是不良代码
-- Notes:
EXEC dbo.uspSave_Die_AOIPicked_WithDefect
    @LotWafer = 'LN12345-W01',
    @ChipSN_DefectCode = 'B03-402:1-HH,B03-403:10-GK';

Change Log:
-- =============================================
*/
CREATE   PROCEDURE [dbo].[uspSave_Die_AOIPicked_WithDefect]
(
    @LotWafer            varchar(20),
    @ChipSN_DefectCode   varchar(max)
)
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb..#Src') IS NOT NULL DROP TABLE #Src;
    IF OBJECT_ID('tempdb..#Parsed') IS NOT NULL DROP TABLE #Parsed;

    CREATE TABLE #Src
    (
        Item varchar(200) NOT NULL
    );

    CREATE TABLE #Parsed
    (
        ChipSN          varchar(50)  NOT NULL,
        DefectAreaCode  varchar(20)  NOT NULL,
        DefectTypeCode  varchar(20)  NOT NULL,
        DefectCode      varchar(50)  NOT NULL
    );

    INSERT INTO #Src(Item)
    SELECT LTRIM(RTRIM(f.MyColumn))
    FROM dbo.ufnGetListFromSourceString(@ChipSN_DefectCode, ',') f
    WHERE LTRIM(RTRIM(f.MyColumn)) <> '';

    INSERT INTO #Parsed
    (
        ChipSN,
        DefectAreaCode,
        DefectTypeCode,
        DefectCode
    )
    SELECT
        ChipSN = LTRIM(RTRIM(LEFT(s.Item, CHARINDEX(':', s.Item) - 1))),
        DefectAreaCode = LTRIM(RTRIM(LEFT(DefectPart.DefectCode, CHARINDEX('-', DefectPart.DefectCode) - 1))),
        DefectTypeCode = LTRIM(RTRIM(SUBSTRING(DefectPart.DefectCode, CHARINDEX('-', DefectPart.DefectCode) + 1, LEN(DefectPart.DefectCode)))),
        DefectCode = DefectPart.DefectCode
    FROM #Src s
    CROSS APPLY
    (
        SELECT DefectCode = LTRIM(RTRIM(SUBSTRING(s.Item, CHARINDEX(':', s.Item) + 1, LEN(s.Item))))
    ) DefectPart
    WHERE CHARINDEX(':', s.Item) > 0
      AND CHARINDEX('-', DefectPart.DefectCode) > 0;

    INSERT INTO dbo.Die_AOIPicked
    (
        DieID,
        DefectAreaCode,
        DefectTypeCode,
        DefectCode
    )
    SELECT DISTINCT
        d.DieID,
        p.DefectAreaCode,
        p.DefectTypeCode,
        p.DefectCode
    FROM dbo.Die d
    INNER JOIN #Parsed p
        ON d.Cbin = p.ChipSN
    LEFT JOIN dbo.Die_AOIPicked da
        ON da.DieID = d.DieID
    WHERE d.LotWafer = @LotWafer
      AND da.DieID IS NULL;
END;