/*
2025/12/03 Jackie Chen

exec dbo.usp_AssignWafer  'LN42467-W01', 12, 10, 1
exec dbo.usp_AssignWafer  'LN42467-W01', 12, 10, 7
SELECT * FROM dbo.Die d WHERE LotWafer = 'LN42467-W01' and Bin=1
    ORDER BY Seqid;

Change Log:
*/
CREATE   PROC [dbo].[usp_AssignWafer]
(
    @LotWafer   varchar(20),
    @Box_X  int,             -- e.g. 12
    @Box_Y  int,             -- e.g. 10
    @Bin    int
)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM dbo.Die d WHERE d.LotWafer = @LotWafer and Bin = @Bin AND d.BoxNo IS NULL)
    BEGIN
        IF OBJECT_ID('TEMPDB..#Die') IS NOT NULL DROP TABLE #Die    
        SELECT d.LotWafer, Seqid=ROW_NUMBER() OVER(ORDER BY d.Seqid), d.Cbin, d.Die_Location, d.Dev_ID, d.Bin
            INTO #Die
            FROM dbo.Die d
            WHERE d.LotWafer = @LotWafer and Bin = @Bin
        
        DECLARE @ExistedBox INT
        SELECT @ExistedBox=MAX(d.BoxNo) FROM dbo.Die d WHERE d.LotWafer = @LotWafer AND d.BoxNo IS NOT NULL
        SELECT @ExistedBox=ISNULL(@ExistedBox, 0)
        Print '--@ExistedBox: ' + CONVERT(VARCHAR(MAX),@ExistedBox)
        UPDATE d SET d.BoxNo=(z.Seqid-1)/(@Box_X*@Box_Y)+1+@ExistedBox
            , d.AOI_name=[dbo].ufnGetBoxPosition(z.Seqid, @Box_X, @Box_Y)
            FROM #Die z
            JOIN dbo.Die d on z.LotWafer=d.LotWafer AND Z.Cbin=d.Cbin
            WHERE z.Seqid>0
    END

    SELECT
        d.LotWafer,
        d.Seqid,
        d.Cbin,
        d.Bin,
        d.BoxNo,
        d.AOI_name
    FROM dbo.Die AS d
    WHERE d.LotWafer = @LotWafer and Bin = @Bin
    ORDER BY D.Seqid;

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_AssignWafer] TO [Production]
    AS [dbo];

