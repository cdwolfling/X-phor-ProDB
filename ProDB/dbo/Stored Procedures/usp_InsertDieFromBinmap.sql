/*
2025/12/03 Jackie Chen
Rule:
要求写入Retical_Y*10*Retical_X*10笔数据到dbo.Die表, 其中
    LotWafer=@LotWafer
    Seqid从1～@Total
    Die_Location是Cbin的左边3位
    Diev_ID是Cbin的右边3位
    Bin来自@Binmap
    Cbin总计7位数，规则会在下面给出:
        芯片的排序是从第一行排到第40行， 单数行从左到右， 偶数行从右到左
        第1位: (从左到右分别是)将A～J每个字母排Retical_X遍
        第2-3位: 行号， 从00排到10, 每个行号重复Retical_Y次
        第4位: -
        第5位: (从左到右分别是)数字Retical_Y~1排Retical_X遍
        第6位: 0
        第7位: (从左到右分别是)数字1~Retical_X,排10遍

--Test:
exec dbo.usp_InsertDieFromBinmap
    @LotWafer = 'LN42467-W01'
    ,@Retical_X = 3
    ,@Retical_Y = 4
    ,@Binmap =
'0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	0	0	0	3	0	7	7	0	0	0	0	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	0	0	7	7	7	7	7	7	7	7	0	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	2	7	7	7	7	7	7	7	7	7	7	7	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	7	7	1	7	7	7	1	7	1	1	1	1	1	1	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	7	7	7	1	1	7	1	1	1	1	7	1	1	2	1	1	0	0	0	0	0	0	0
0	0	0	0	0	0	7	7	7	7	7	7	2	1	2	7	1	7	1	1	1	1	1	2	0	0	0	0	0	0
0	0	0	0	0	0	7	7	7	7	7	7	7	7	1	7	7	7	1	1	1	1	1	1	1	0	0	0	0	0
0	0	0	0	0	7	7	7	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	2	0	0	0	0	0
0	0	0	0	7	7	1	7	1	1	7	1	1	7	7	1	1	1	1	1	1	1	1	1	2	1	0	0	0	0
0	0	0	0	7	7	7	7	7	7	7	7	7	2	7	7	1	1	1	1	1	2	1	1	1	1	0	0	0	0
0	0	0	7	7	7	7	7	7	7	7	7	7	7	7	7	7	1	2	1	1	1	1	1	1	1	1	0	0	0
0	0	0	1	1	7	7	7	2	1	7	2	1	7	1	1	1	1	1	1	1	1	1	2	1	1	2	0	0	0
0	0	0	2	7	1	7	1	1	7	7	1	7	1	1	1	1	1	1	1	1	1	1	1	1	1	1	0	0	0
0	0	0	7	7	7	7	7	7	7	1	7	7	7	1	7	1	1	1	1	1	1	1	1	1	1	1	1	0	0
0	0	7	7	7	7	7	7	7	7	7	7	7	7	1	7	1	2	1	2	1	1	2	1	1	1	1	1	0	0
0	0	7	7	1	1	1	1	7	1	1	1	1	1	1	1	1	1	1	1	1	1	1	2	1	1	1	1	0	0
0	0	7	7	1	1	7	2	7	1	1	7	1	1	7	1	1	1	1	1	1	1	1	1	1	1	1	1	0	0
0	0	7	7	1	7	7	1	7	1	1	1	1	7	1	7	1	1	1	1	1	1	2	1	1	1	1	1	0	0
0	0	7	7	1	7	7	7	7	1	1	1	7	7	2	1	1	1	1	1	1	1	1	1	2	1	2	1	0	0
0	0	7	7	7	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	2	1	2	1	0	0
0	0	7	1	2	1	1	1	1	1	1	1	1	1	2	1	1	1	1	1	1	1	1	1	1	1	1	1	0	0
0	0	7	1	7	7	7	1	1	1	1	7	1	1	1	7	1	1	1	1	1	1	1	1	1	1	1	1	0	0
0	0	7	7	7	1	2	1	1	1	1	1	7	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	0	0
0	0	7	1	1	2	2	1	1	1	1	2	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	0	0
0	0	0	1	1	1	2	1	1	2	1	2	1	2	1	1	1	1	1	2	1	1	1	1	1	1	1	1	0	0
0	0	0	1	2	2	1	1	1	7	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	0	0	0
0	0	0	1	1	1	7	1	1	7	1	1	1	1	1	2	1	1	1	1	1	2	1	1	1	1	2	0	0	0
0	0	0	1	1	1	7	1	1	1	1	1	1	1	2	1	1	1	1	1	1	1	1	2	1	1	2	0	0	0
0	0	0	0	1	1	2	1	2	1	2	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	0	0	0	0
0	0	0	0	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	0	0	0	0
0	0	0	0	0	1	1	2	7	2	1	1	1	1	1	1	1	1	1	2	1	1	1	1	1	0	0	0	0	0
0	0	0	0	0	0	2	7	2	1	1	1	1	1	1	2	1	1	1	2	1	1	1	1	2	0	0	0	0	0
0	0	0	0	0	0	2	1	1	1	1	1	1	2	1	1	1	1	1	1	1	1	1	1	0	0	0	0	0	0
0	0	0	0	0	0	0	1	1	1	1	1	1	1	1	1	1	2	1	1	2	1	1	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	1	1	1	2	1	1	1	1	2	2	2	1	1	1	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	1	1	1	2	2	1	1	1	1	1	1	2	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	0	0	1	1	2	1	1	1	1	1	0	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	2	1	1	1	0	0	0	0	0	0	0	0	0	0	0	0	0
0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
'

SELECT * FROM dbo.Die d WHERE LotWafer = 'LN42467-W01'
    ORDER BY Seqid;

Change Log:
2026-02-03 JC: 兼容Coral4p5/6p5这种 Binmap_X /Retical_X>10的情况
2025-12-23 JC: 允许Traveler(Microsoft Office)重复导入
2025-12-18 JC: Add TRANSACTION
2025-12-16 JC: Add new input parameters @Die_Count
2025-12-13 JC: Add new input parameters @Cols/@Rows
*/
CREATE   PROC [dbo].[usp_InsertDieFromBinmap]
(
    @LotWafer   varchar(20),
    @Retical_X  int,             -- e.g. 3
    @Retical_Y  int,             -- e.g. 4
    @Binmap      nvarchar(max),
    @Cols      int = NULL,
    @Rows      int = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @CallerApp NVARCHAR(128) = APP_NAME();
    
    SELECT @Cols = ISNULL(@Cols, @Retical_X * 10)
    SELECT @Rows = ISNULL(@Rows, @Retical_Y * 10)
    DECLARE @Total int = @Rows * @Cols;            -- 总die数 (应为 Retical_X*10 * Retical_Y*10)
    IF @Binmap IS NULL OR LTRIM(RTRIM(@Binmap)) = N''
    BEGIN
        RAISERROR('Bnmap is empty.', 16, 1);
        RETURN;
    END

    IF OBJECT_ID('TEMPDB..#BinsCTE') IS NOT NULL DROP TABLE #BinsCTE
    IF OBJECT_ID('TEMPDB..#DieTemp') IS NOT NULL DROP TABLE #DieTemp

    ----------------------------------------------------------------------
    -- 1) 把 @Binmap 解析成 (RowIndex, ColIndex, Bin) 结构
    ----------------------------------------------------------------------
    DECLARE @xmlRows xml;

    -- 只保留 LF 作为换行, 兼容Tab和空格
    SET @Binmap = REPLACE(@Binmap, CHAR(13), N'');
    SET @Binmap = REPLACE(@Binmap, CHAR(9), N' ');

    -- 每一行变成 <r> 节点
    SET @xmlRows = CAST(
        N'<root><r>'
        + REPLACE(@Binmap, CHAR(10), N'</r><r>')
        + N'</r></root>' AS xml
    );
        
    ;WITH RowsCTE AS
    (
        SELECT
            ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS RowIndex, -- 0-based
            LTRIM(RTRIM(T.N.value('.', 'nvarchar(max)'))) AS Line
        FROM @xmlRows.nodes('/root/r') AS T(N)
        WHERE LTRIM(RTRIM(T.N.value('.', 'nvarchar(max)'))) <> N''
    ),
    BinsCTE AS
    (
        SELECT
            R.RowIndex,
            ROW_NUMBER() OVER (PARTITION BY R.RowIndex ORDER BY (SELECT NULL)) - 1 AS ColIndex,  -- 0-based
            TRY_CAST(C.C.value('.', 'int') AS int) AS Bin
        FROM RowsCTE AS R
        CROSS APPLY
        (
            SELECT CAST(
                N'<r><c>'
                + REPLACE(R.Line, N' ', N'</c><c>')
                + N'</c></r>' AS xml
            ) AS LineXml
        ) AS X
        CROSS APPLY X.LineXml.nodes('/r/c') AS C(C)
    )
    SELECT * INTO #BinsCTE FROM BINSCTE
    
    ----------------------------------------------------------------------
    -- 2) 准备#DieTemp用于输出/insert
    ----------------------------------------------------------------------
    ;WITH SeqCTE AS
    (
        -- 根据“行1→行40；单数行从左到右，双数行从右到左”生成 Seqid
        SELECT
            B.RowIndex,
            B.ColIndex,
            B.Bin,
            PosInRow = CASE WHEN (B.RowIndex % 2) = 0      -- RowIndex 0 -> 第1行(奇数行) 左→右
                            THEN B.ColIndex
                            ELSE (@Cols - 1 - B.ColIndex)  -- 偶数行 右→左
                       END,
            Seqid = B.RowIndex * @Cols
                  + CASE WHEN (B.RowIndex % 2) = 0
                         THEN B.ColIndex
                         ELSE (@Cols - 1 - B.ColIndex)
                    END
                  + 1
        FROM #BinsCTE AS B
    ),
    FinalCTE AS
    (
        SELECT
            S.Seqid,
            S.Bin,
            Cbin =
                CONCAT(
                    ----------------------------------------------------------------
                    -- 第1位: A~J，每个字母重复 Retical_X 次，按 Seqid 顺序循环
                    ----------------------------------------------------------------
                    SUBSTRING(
                        'ABCDEFGHIJK',  -- 11 个字母
                        (S.ColIndex / @Retical_X) + 1,
                        1
                    ),
                    ----------------------------------------------------------------
                    -- 第2-3位: 行号 00~09，每个行号覆盖 Retical_Y 行
                    -- 行号只与 RowIndex 有关: RowIndex / Retical_Y
                    ----------------------------------------------------------------
                    RIGHT(
                        '0' + CAST( ( S.RowIndex / @Retical_Y ) AS varchar(2) ),
                        2
                    ),
                    ----------------------------------------------------------------
                    -- 第4位: 固定为 '-'
                    ----------------------------------------------------------------
                    '-',
                    ----------------------------------------------------------------
                    -- 第5位: 数字 @Retical_Y~1 循环（即 4321 重复）
                    ----------------------------------------------------------------
                    @Retical_Y - (S.RowIndex % @Retical_Y),
                    ----------------------------------------------------------------
                    -- 第6位: 固定 0
                    ----------------------------------------------------------------
                    '0',
                    ----------------------------------------------------------------
                    -- 第7位: 数字 1~@Retical_X 循环（123123...）
                    ----------------------------------------------------------------
                    S.ColIndex % @Retical_X + 1
                )
        FROM SeqCTE AS S
    )
    SELECT * INTO #DieTemp
    FROM FinalCTE;

    ----------------------------------------------------------------------
    -- 校验数目
    ----------------------------------------------------------------------
    Declare @SeqCTE_Count int
    SELECT @SeqCTE_Count=COUNT(*) FROM #DieTemp
    IF @SeqCTE_Count <> @Total
    BEGIN
        DROP TABLE #DieTemp;
        RAISERROR('Parsed die count (%d) does not match expected total (%d).',
                  16, 1, @SeqCTE_Count, @Total);
        RETURN;
    END
    Declare @Die_Count int
    SELECT @Die_Count=COUNT(*) FROM dbo.Die WHERE LotWafer = @LotWafer;
    IF @Die_Count >= @SeqCTE_Count AND @CallerApp <> 'Microsoft Office'
    BEGIN
        DROP TABLE #DieTemp;
        RAISERROR('dbo.die count (%d) >= new insert count (%d).',
                  16, 1, @Die_Count, @SeqCTE_Count);
        RETURN;
    END

    ----------------------------------------------------------------------
    -- 3) 插入 Die 表
    ----------------------------------------------------------------------
    BEGIN TRY
        BEGIN TRANSACTION;

        IF EXISTS(SELECT 1 FROM dbo.Die WHERE LotWafer = @LotWafer)
            DELETE FROM dbo.Die WHERE LotWafer = @LotWafer;

        INSERT INTO dbo.Die (LotWafer, Seqid, Cbin, Die_Location, Dev_ID, Bin, BoxNo, AOI_name)
            SELECT @LotWafer, D.Seqid, D.Cbin, LEFT(D.Cbin,3), RIGHT(D.Cbin,3), D.Bin, NULL, NULL
            FROM #DieTemp AS D ORDER BY D.Seqid;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE 
            @ErrorMessage NVARCHAR(4000),
            @ErrorSeverity INT,
            @ErrorState INT;
        SELECT
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();
        RAISERROR (
            @ErrorMessage,  -- 异常描述
            @ErrorSeverity, -- 严重级别
            @ErrorState     -- 状态码
        );
    END CATCH;

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_InsertDieFromBinmap] TO [Production]
    AS [dbo];

