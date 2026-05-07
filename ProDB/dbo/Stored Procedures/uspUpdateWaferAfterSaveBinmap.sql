/*
2026-05-07 Jackie Chen

Change Log:
*/
CREATE   PROCEDURE [dbo].[uspUpdateWaferAfterSaveBinmap]
    @ProductFamily VARCHAR(20),
    @LotWafer      VARCHAR(20),
    @SpecVersion   VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Now DATETIME;
    SET @Now = GETDATE();
    
    IF ISNULL(@SpecVersion,'')=''
    BEGIN
        SELECT @SpecVersion=spec.SpecVersion FROM spec.ProductFamilySpec spec WHERE spec.IsActive=1 and spec.ProductFamily=@ProductFamily
    END
    IF ISNULL(@SpecVersion,'')=''
    BEGIN
        SELECT @SpecVersion=spec.SpecVersion FROM spec.ProductFamilySpec spec WHERE spec.IsActive=1 and spec.ProductFamily=LEFT(@ProductFamily, 8)
    END

    BEGIN TRY
        BEGIN TRAN;

        UPDATE dbo.Wafer WITH (UPDLOCK, HOLDLOCK)
        SET
            Binmap_SpecVersion = @SpecVersion,
            Binmap_ImportTime = @Now
        WHERE
            Wafer号 = @LotWafer;

        /*
            如果没有更新到任何记录，则新增
        */
        IF @@ROWCOUNT = 0
        BEGIN
            INSERT INTO dbo.Wafer
            (
                Wafer号,
                Binmap_SpecVersion,
                Binmap_ImportTime
            )
            VALUES
            (
                @LotWafer,
                @SpecVersion,
                @Now
            );
        END

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;

        THROW;
    END CATCH
END