
/*
-- =============================================
-- Author:		Jackie Chen
-- Create date: 2026/1/27
-- Description:	如果文件已存在， 返回StatusCode = 1001， 否则产生文件记录并返回FileID
-- Notes:

Change Log:
-- =============================================
*/
CREATE   PROCEDURE [dbo].[uspGenerateFileID_ToHandlingCPData]
(
    @ProductModel      varchar(8),
    @LotWafer          varchar(11),
    @FilePath          varchar(400),
    @FileModifiedTime  datetime
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @StatusCode int = 0;
    DECLARE @FileID bigint = -1;

    BEGIN TRY
        BEGIN TRAN;

        -- 并发保护：同一 LotWafer + FileModifiedTime 在事务内锁定判断
        IF EXISTS (
            SELECT 1
            FROM dbo.CPTest_File WITH (UPDLOCK, HOLDLOCK)
            WHERE LotWafer = @LotWafer
              AND FileModifiedTime = @FileModifiedTime
        )
        BEGIN
            UPDATE f SET f.CPTest_TrackOutTime = w.测试结束时间
                FROM dbo.CPTest_File f
                JOIN dbo.Wafer w ON w.Wafer号 = f.LotWafer
                WHERE f.LotWafer = @LotWafer
                  AND (f.CPTest_TrackOutTime IS NULL OR f.CPTest_TrackOutTime < w.测试结束时间);
            SELECT @StatusCode = 1001, @FileID = -1;

            COMMIT TRAN;

            SELECT StatusCode = @StatusCode, FileID = @FileID;
            RETURN;
        END

        -- isRecent 处理：该 LotWafer 旧记录置 0
        UPDATE dbo.CPTest_File SET isRecent = 0
            WHERE LotWafer = @LotWafer AND isRecent = 1;

        DECLARE @CPTest_TrackOutTime DATETIME
        SELECT @CPTest_TrackOutTime=w.测试结束时间 FROM dbo.Wafer w WHERE w.Wafer号 = @LotWafer
        INSERT INTO dbo.CPTest_File (ProductModel, LotWafer, Station, FilePath, FileModifiedTime, CPTest_TrackOutTime, isRecent)
            VALUES (@ProductModel, @LotWafer, [dbo].[ufnGetStation_FromCPTestFilePath](@FilePath), @FilePath, @FileModifiedTime, @CPTest_TrackOutTime, 1);

        SET @FileID = SCOPE_IDENTITY();
        SET @StatusCode = 0;

        COMMIT TRAN;

        SELECT StatusCode = @StatusCode, FileID = @FileID;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;

        -- 如果并发导致唯一键冲突，也可按“已存在”处理
        -- 2601/2627 = 唯一键/主键冲突
        IF ERROR_NUMBER() IN (2601, 2627)
        BEGIN
            SELECT StatusCode = 1001, FileID = -1;
            RETURN;
        END

        DECLARE @Err nvarchar(2048) = CONCAT(
            'uspGenerateFileID_ToHandlingCPData failed. ',
            'Error=', ERROR_NUMBER(), ', Line=', ERROR_LINE(), ', Msg=', ERROR_MESSAGE()
        );

        -- 你也可以改成 RETURN 非0；这里用 RAISERROR 把错误抛给调用方
        RAISERROR(@Err, 16, 1);
    END CATCH
END