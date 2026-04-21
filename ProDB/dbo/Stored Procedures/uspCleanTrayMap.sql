

/*==============================================================
Create on 2026-04-20 uspCleanTrayMap
==============================================================*/
CREATE   PROCEDURE [dbo].[uspCleanTrayMap]
    @ProductModel   VARCHAR(20),
    @Lot            VARCHAR(7),
    @Wafer          VARCHAR(3),
    @TrayNo         INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    CREATE TABLE #TrayMapToClean
    (
        TrayMapId BIGINT NOT NULL PRIMARY KEY
    );

    INSERT INTO #TrayMapToClean
    (
        TrayMapId
    )
    SELECT H.TrayMapId
    FROM dbo.TrayMapHeader AS H
    WHERE H.ProductModel = @ProductModel
      AND H.LotNo        = @Lot
      AND H.Wafer        = @Wafer
      AND TRY_CONVERT(INT, H.TrayNo) = @TrayNo;

    IF NOT EXISTS (SELECT 1 FROM #TrayMapToClean)
    BEGIN
        SELECT
            CAST(0 AS INT) AS HeaderBackedUp,
            CAST(0 AS INT) AS CellBackedUp,
            CAST(0 AS INT) AS HeaderDeleted,
            CAST(0 AS INT) AS CellDeleted,
            N'No matching TrayMap record found.' AS [Message];
        RETURN;
    END;

    DECLARE @HeaderBackedUp INT = 0;
    DECLARE @CellBackedUp   INT = 0;
    DECLARE @HeaderDeleted  INT = 0;

    BEGIN TRY
        BEGIN TRAN;

        /* 1. Backup Header */
        INSERT INTO dbo.TrayMapHeader_History
        (
            TrayMapId,
            LotWaferTrayKey,
            ProductModel,
            LotNo,
            Wafer,
            LotWafer,
            TrayNo,
            OQCTrackOutTime,
            Cdt,
            Udt
        )
        SELECT
            H.TrayMapId,
            H.LotWaferTrayKey,
            H.ProductModel,
            H.LotNo,
            H.Wafer,
            H.LotWafer,
            H.TrayNo,
            H.OQCTrackOutTime,
            H.Cdt,
            H.Udt
        FROM dbo.TrayMapHeader AS H
        INNER JOIN #TrayMapToClean AS T
            ON H.TrayMapId = T.TrayMapId;

        SET @HeaderBackedUp = @@ROWCOUNT;

        /* 2. Backup Cell */
        INSERT INTO dbo.TrayMapCell_History
        (
            TrayMapId,
            RowNo,
            ColNo,
            SeqAtTray,
            ChipSN,
            Udt
        )
        SELECT
            C.TrayMapId,
            C.RowNo,
            C.ColNo,
            C.SeqAtTray,
            C.ChipSN,
            C.Udt
        FROM dbo.TrayMapCell AS C
        INNER JOIN #TrayMapToClean AS T
            ON C.TrayMapId = T.TrayMapId;

        SET @CellBackedUp = @@ROWCOUNT;

        /* 3. Delete Header
              TrayMapCell will be deleted automatically by ON DELETE CASCADE */
        DELETE H
        FROM dbo.TrayMapHeader AS H
        INNER JOIN #TrayMapToClean AS T
            ON H.TrayMapId = T.TrayMapId;

        SET @HeaderDeleted = @@ROWCOUNT;

        COMMIT TRAN;

        SELECT
            @HeaderBackedUp               AS HeaderBackedUp,
            @CellBackedUp                 AS CellBackedUp,
            @HeaderDeleted                AS HeaderDeleted,
            @CellBackedUp                 AS CellDeleted,
            N'Backup and clean completed.' AS [Message];
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;

        THROW;
    END CATCH
END