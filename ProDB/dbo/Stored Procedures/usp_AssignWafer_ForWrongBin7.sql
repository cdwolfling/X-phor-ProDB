/*
2025/12/03 Jackie Chen

exec dbo.usp_AssignWafer_ForWrongBin7  'LN41477-W07', 12, 10, 7
exec dbo.usp_AssignWafer_ForWrongBin7  'LN41477-W07', 12, 10, 8
SELECT * FROM dbo.Die_WrongBin7 d WHERE LotWafer = 'LN41477-W07' and Bin=7
SELECT * FROM dbo.Die_WrongBin7 d WHERE LotWafer = 'LN41477-W07' and newBin=7
    ORDER BY Seqid;

Change Log:
2026-03-27 JC: 修正Bin8 @ExistedBox 不准确的问题
*/
CREATE     PROC [dbo].[usp_AssignWafer_ForWrongBin7]
(
    @LotWafer   varchar(20),
    @Box_X  int,             -- e.g. 12
    @Box_Y  int,             -- e.g. 10
    @newBin    int
)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM dbo.Die_WrongBin7 d WHERE d.LotWafer = @LotWafer and newBin = @newBin AND d.newBoxNo IS NULL)
    BEGIN
        IF OBJECT_ID('TEMPDB..#Die') IS NOT NULL DROP TABLE #Die    
        SELECT d.LotWafer, Seqid=ROW_NUMBER() OVER(ORDER BY d.Seqid), d.Cbin, d.Die_Location, d.Dev_ID, d.Bin
            INTO #Die
            FROM dbo.Die_WrongBin7 d
            WHERE d.LotWafer = @LotWafer and newBin = @newBin
        
        DECLARE @ExistedBox INT
        SELECT @ExistedBox=MAX(d.newBoxNo) FROM dbo.Die_WrongBin7 d WHERE d.LotWafer = @LotWafer AND d.newBoxNo IS NOT NULL
        if @ExistedBox is null
        begin
            if @newBin=7
                select @ExistedBox=9-1 --装入tray09/10
            else if @newBin=8
                select @ExistedBox=11-1  --装入tray11/12
        end
        else
        begin
            if @newBin=8 and @ExistedBox<11-1
                select @ExistedBox=11-1  --装入tray11/12
        end


        Print '--@ExistedBox: ' + CONVERT(VARCHAR(MAX),@ExistedBox)
        UPDATE d SET d.newBoxNo=(z.Seqid-1)/(@Box_X*@Box_Y)+1+@ExistedBox
            , d.newAOI_name=[dbo].ufnGetBoxPosition(z.Seqid, @Box_X, @Box_Y)
            FROM #Die z
            JOIN dbo.Die_WrongBin7 d on z.LotWafer=d.LotWafer AND Z.Cbin=d.Cbin
            WHERE z.Seqid>0
    END

    SELECT
        @LotWafer AS LotWafer,
        d.Seqid,
        d.Cbin,
        --d.Die_Location,
        --d.Dev_ID,
        d.Bin,
        d.newBoxNo,
        d.AOI_name
    FROM dbo.Die_WrongBin7 AS d
    WHERE d.LotWafer = @LotWafer and newBin = @newBin
    ORDER BY D.Seqid;

END