/*
-- Author:		Jackie Chen
-- Create date: 2026-02-08
-- Description:	导入SY Tray SN信息
-- Notes:
exec dbo.uspSaveTrayMap_SY 
@Lot_Wafer_Box_ID=N'LN44129-W09-01',@Box_X=18,@Box_Y=14,@ChipSNs=N'F00-105,F00-104,F00-103,F00-102,F00-101,E00-106,E00-105,E00-104,E00-103,,D01-403
,D01-404,D01-405,E01-401,E01-402,E01-403,E01-404,E01-405,F01-304,F01-306,G01-301,G01-302,G01-303,G01-304,G01-305,H01-301,G01-404,G01-403,G01-402,G01-401
,F01-406,F01-405,F01-404,F01-403,F01-401,E01-406,F01-303,F01-302,F01-301,E01-306,E01-305,E01-304,E01-303,E01-301,D01-306,D01-304,D01-303,D01-302,D01-301
,C01-306,C01-204,C01-205,C01-206,D01-202,G01-202,G01-201,F01-206,F01-205,F01-204,F01-203,F01-202,F01-201,E01-206,E01-205,E01-204,E01-203,E01-202,E01-201
,D01-206,D01-205,D01-204,D01-203,G01-203,G01-205,G01-206,H01-201,H01-202,,H01-105,H01-104,H01-103,H01-102,H01-101,G01-106,G01-105,G01-104,G01-103,G01-102
,G01-101,F01-106,C01-105,C01-106,D01-101,D01-102,D01-103,D01-104,D01-105,D01-106,E01-101,E01-102,E01-103,E01-104,E01-106,F01-101,F01-102,F01-103,F01-104
,F01-105,C01-104,C01-103,C01-102,C02-401,C02-403,C02-404,C02-405,C02-406,D02-401,D02-402,D02-404,D02-405,E02-401,E02-402,E02-403,E02-404,E02-405,E02-406
,H02-406,H02-405,H02-404,H02-403,H02-402,H02-401,G02-406,G02-405,G02-404,G02-403,G02-402,G02-401,F02-406,F02-405,F02-404,F02-403,F02-402,,I02-401,I02-302
,I02-301,H02-306,H02-305,H02-304,H02-303,H02-302,H02-301,G02-306,G02-305,G02-303,G02-302,G02-301,F02-306,F02-305,F02-304,F02-303,C02-301,C02-302,C02-303
,C02-304,C02-305,C02-306,D02-301,D02-302,D02-303,D02-304,D02-305,D02-306,E02-301,E02-303,E02-304,E02-306,F02-301,F02-302,B02-306,B02-305,B02-204,B02-205
,B02-206,C02-201,C02-202,C02-204,C02-206,D02-201,D02-202,D02-203,D02-204,D02-205,D02-206,E02-201,E02-202,E02-204,H02-204,H02-203,H02-202,H02-201,G02-206
,G02-205,G02-204,G02-203,G02-202,G02-201,F02-206,F02-205,F02-204,F02-203,F02-202,F02-201,E02-206,E02-205,H02-205,H02-206,I02-201,I02-202,I02-203,I02-104
,I02-103,I02-102,I02-101,H02-106,H02-105,H02-104,H02-103,H02-102,H02-101,G02-106,G02-105,G02-104,D02-104,D02-105,D02-106,E02-101,E02-102,E02-103,E02-104
,E02-105,E02-106,F02-101,F02-102,F02-103,F02-104,F02-105,F02-106,G02-101,G02-102,G02-103'


Change Log:
*/
CREATE     PROCEDURE [dbo].[uspSaveTrayMap_SY](
    @Lot_Wafer_Box_ID VARCHAR(14),
    @Box_X             INT,
    @Box_Y            INT,
    @ChipSNs           NVARCHAR(MAX)   -- @Box_X * @Box_Y 个，用逗号串起来，允许空
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    
    select @ChipSNs=REPLACE(@ChipSNs,char(13),'')
    select @ChipSNs=REPLACE(@ChipSNs,char(10),'')

    DECLARE
        @TrayMapId         BIGINT,
        @ProductModel             VARCHAR(15),
        @Lot             VARCHAR(7),
        @Wafer             VARCHAR(3),
        @TrayNo   VARCHAR(2),
        @LotWaferTrayKey   VARCHAR(30),
        @OQCTrackoutTime   DATETIME,
        @sql               NVARCHAR(MAX);
        
    SET @Lot = LEFT(@Lot_Wafer_Box_ID,7)
    SET @Wafer = substring(@Lot_Wafer_Box_ID,9,3)
    SET @TrayNo = RIGHT(@Lot_Wafer_Box_ID,2)
    SET @LotWaferTrayKey = CONCAT(@Lot, '-', @Wafer, '-', @TrayNo);
    select @ProductModel=w.Project from dbo.Shipping_list w where w.Lot_Wafer_Box_ID=@LotWaferTrayKey

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
                VALUES (@LotWaferTrayKey, @ProductModel, @Lot, @Wafer, @Lot+'-'+@Wafer, @TrayNo, @OQCTrackoutTime);
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
                ROW_NUMBER() OVER
                (
                    ORDER BY
                        C.RowNo ASC,
                        C.ColNo ASC
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

        update s set s.ImportTraySN_Cdt=GETDATE(), s.Udt=GETDATE() from Shipping_list s where s.Site='SY' and s.Lot_Wafer_Box_ID=@Lot_Wafer_Box_ID

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

        RAISERROR(N'uspSaveTrayMap_SY failed. [%d] %s (Proc=%s Line=%d)', @ErrNum, @ErrMsg, @ErrPro, @ErrLin);
        RETURN;
    END CATCH
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[uspSaveTrayMap_SY] TO [Production]
    AS [dbo];

