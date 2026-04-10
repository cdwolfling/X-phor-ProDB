/*
2026-01-28 JC: 用@Box_X @Box_Y兼容多ProductModel
2026-01-25 JC: 保存OQCTrackoutTime时，允许为Null
2026-01-24 JC: 保存Tray的Map信息
*/
CREATE   PROCEDURE [dbo].[uspSaveTrayMap]
    @ProductModel      VARCHAR(8),
    @Lot               VARCHAR(7),
    @Wafer             VARCHAR(3),
    @TrayNo            INT,
    @ChipSNs           NVARCHAR(MAX)   -- @Box_X * @Box_Y 个，用逗号串起来，允许空
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @TrayMapId         BIGINT,
        @TrayNo_char   VARCHAR(2),
        @LotWaferTrayKey   VARCHAR(30),
        @OQCTrackoutTime   DATETIME,
        @sql               NVARCHAR(MAX);
    SELECT @TrayNo_char = REPLACE(STR(@TrayNo, 2), ' ', '0')

    -- 你们现表是 LotWaferTrayKey 唯一，这里用最稳妥的拼法（不带分隔符，长度也足够）
    SET @LotWaferTrayKey = CONCAT(@Lot, '-', @Wafer, '-', @TrayNo_char);
    SELECT @OQCTrackoutTime = w.OQC结束时间 FROM dbo.Wafer w WHERE w.Lot号 = @Lot AND w.Wafer号 = @Lot + '-' + @Wafer

    DECLARE @Box_X INT, @Box_Y INT
    SELECT @Box_X = p.Box_X, @Box_Y = p.Box_Y FROM dbo.ProductModel p WHERE p.ProductModel = @ProductModel

    BEGIN TRY
        BEGIN TRAN;

        /* 1) Header：不存在则插入，存在则只更新时间列，并拿到 TrayMapId */
        -- 先锁住目标 Key，避免并发插入重复
        SELECT @TrayMapId = H.TrayMapId
            FROM dbo.TrayMapHeader H WITH (UPDLOCK, HOLDLOCK)
            WHERE H.LotWaferTrayKey = @LotWaferTrayKey;
        IF @TrayMapId IS NULL
        BEGIN
            INSERT dbo.TrayMapHeader (LotWaferTrayKey, ProductModel, LotNo, Wafer, LotWafer, TrayNo, OQCTrackOutTime)
                VALUES (@LotWaferTrayKey, @ProductModel, @Lot, @Wafer, @Lot+'-'+@Wafer, @TrayNo_char, @OQCTrackoutTime);
            SELECT @TrayMapId = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            UPDATE dbo.TrayMapHeader
                SET OQCTrackoutTime = @OQCTrackoutTime, Udt = GETDATE()
                WHERE TrayMapId = @TrayMapId
        END

        /* 2) 解析 ChipSNs -> 临时表（参考 TrayMapCell 结构） */
        IF OBJECT_ID('tempdb..#Raw') IS NOT NULL DROP TABLE #Raw;
        IF OBJECT_ID('tempdb..#TrayMapCellNew') IS NOT NULL DROP TABLE #TrayMapCellNew;
        CREATE TABLE #Raw
        (
            Pos    INT NOT NULL PRIMARY KEY,
            ChipSN VARCHAR(50) NULL
        );
        
        DECLARE @json nvarchar(max) = N'["' + REPLACE(@ChipSNs, N',', N'","') + N'"]';
        INSERT #Raw(Pos, ChipSN)
            SELECT [key] + 1 AS Pos,value AS ChipSN
            FROM OPENJSON(@json);
            
        -- 构造 1..@Box_X * @Box_Y 的位置（不足补空，超出截断）
        ;WITH N AS
        (
            SELECT Pos FROM #Raw WHERE Pos <= @Box_X * @Box_Y
        ),
        Cells AS
        (
            SELECT
                N.Pos,
                CAST(((N.Pos - 1) / @Box_X) + 1 AS TINYINT) AS RowNo, -- 1..@Box_Y（从上到下）
                CAST(((N.Pos - 1) % @Box_X) + 1 AS TINYINT) AS ColNo, -- 1..@Box_X（从左到右）
                R.ChipSN
            FROM N
            LEFT JOIN #Raw R ON R.Pos = N.Pos
        ),
        NonEmpty AS
        (
            SELECT
                @TrayMapId AS TrayMapId,
                C.RowNo,
                C.ColNo,
                C.ChipSN,
                -- 蛇形走位排序：从右下开始向左；到上一行后反向；依次往复
                ROW_NUMBER() OVER
                (
                    ORDER BY
                        C.RowNo DESC,
                        CASE WHEN ((@Box_Y - C.RowNo) % 2) = 0 THEN C.ColNo END DESC,  -- 底行/偶数偏移：右->左
                        CASE WHEN ((@Box_Y - C.RowNo) % 2) = 1 THEN C.ColNo END ASC    -- 奇数偏移：左->右
                ) AS SeqAtTray
            FROM Cells C
            WHERE C.ChipSN <> ''
        )
        SELECT
            TrayMapId,
            RowNo,
            ColNo,
            SeqAtTray,
            ChipSN
        INTO #TrayMapCellNew
        FROM NonEmpty;

        /* 3) 若与 TrayMapCell 不一致则更新（含：更新/插入/删除空位记录） */
        DECLARE @HasDiff BIT = 0;

        IF EXISTS
        (
            (SELECT TrayMapId, RowNo, ColNo, SeqAtTray, ISNULL(ChipSN,'') AS ChipSN
             FROM dbo.TrayMapCell WITH (READCOMMITTEDLOCK)
             WHERE TrayMapId = @TrayMapId
             EXCEPT
             SELECT TrayMapId, RowNo, ColNo, SeqAtTray, ISNULL(ChipSN,'') AS ChipSN
             FROM #TrayMapCellNew)
            UNION ALL
            (SELECT TrayMapId, RowNo, ColNo, SeqAtTray, ISNULL(ChipSN,'') AS ChipSN
             FROM #TrayMapCellNew
             EXCEPT
             SELECT TrayMapId, RowNo, ColNo, SeqAtTray, ISNULL(ChipSN,'') AS ChipSN
             FROM dbo.TrayMapCell WITH (READCOMMITTEDLOCK)
             WHERE TrayMapId = @TrayMapId)
        )
        BEGIN
            SET @HasDiff = 1;
        END

        IF @HasDiff = 1
        BEGIN
            MERGE dbo.TrayMapCell AS T
            USING #TrayMapCellNew AS S
              ON T.TrayMapId = S.TrayMapId
             AND T.RowNo     = S.RowNo
             AND T.ColNo     = S.ColNo
            WHEN MATCHED AND
                 (T.SeqAtTray <> S.SeqAtTray OR ISNULL(T.ChipSN,'') <> ISNULL(S.ChipSN,''))
                THEN UPDATE
                     SET T.SeqAtTray = S.SeqAtTray, T.ChipSN    = S.ChipSN, T.Udt = GETDATE()
            WHEN NOT MATCHED BY TARGET
                THEN INSERT (TrayMapId, RowNo, ColNo, SeqAtTray, ChipSN)
                     VALUES (S.TrayMapId, S.RowNo, S.ColNo, S.SeqAtTray, S.ChipSN)
            WHEN NOT MATCHED BY SOURCE AND T.TrayMapId = @TrayMapId
                THEN DELETE;
        END

        COMMIT TRAN;

        -- 输出：TrayMapId，以及是否发生了 Cell 变更
        SELECT
            @TrayMapId AS TrayMapId,
            @HasDiff   AS CellUpdated;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;

        DECLARE
            @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE(),
            @ErrNum INT = ERROR_NUMBER(),
            @ErrLin INT = ERROR_LINE(),
            @ErrPro NVARCHAR(200) = ERROR_PROCEDURE();

        RAISERROR(N'uspSaveTrayMap failed. [%d] %s (Proc=%s Line=%d)', @ErrNum, @ErrMsg, @ErrPro, @ErrLin);
        RETURN;
    END CATCH
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[uspSaveTrayMap] TO [Production]
    AS [dbo];

