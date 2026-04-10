/*
-- =============================================
-- Author:		Jackie Chen
-- Create date: 2025/12/01
-- Description:	Refer dbo.Die
-- Notes:
EXEC [dbo].[uspSave_Die_AOIPicked] @LotWafer='LN3385-W06', @Cbin='B03-402'

Change Log:
2026-01-28 JC: 支持多ChipSN的批量插入
-- =============================================
*/
CREATE PROCEDURE [dbo].[uspSave_Die_AOIPicked](
    @LotWafer varchar(20),
    @Cbin     varchar(max)
)
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH CbinList AS
    (
        SELECT DISTINCT Cbin = LTRIM(RTRIM(f.MyColumn))
        FROM dbo.ufnGetListFromSourceString(@Cbin, ',') f
        WHERE f.MyColumn <> ''
    )
    INSERT dbo.Die_AOIPicked(DieID)
        SELECT DISTINCT d.DieID
        FROM dbo.Die AS d
        JOIN CbinList AS l ON d.Cbin = l.Cbin
        LEFT JOIN dbo.Die_AOIPicked AS da ON da.DieID = d.DieID
        WHERE d.LotWafer = @LotWafer
        AND da.DieID is NULL
END;
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[uspSave_Die_AOIPicked] TO [Production]
    AS [dbo];

