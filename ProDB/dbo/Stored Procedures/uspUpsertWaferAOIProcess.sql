
/*
-- =============================================
-- Author:		Jackie Chen
-- Create date: 2026/01/03
-- Description:	用于 X-phor-SaveAOIJsonResultConsole 程序中
-- Notes:

Change Log:
-- =============================================
*/
CREATE PROCEDURE [dbo].[uspUpsertWaferAOIProcess]
    @productModel varchar(8),
    @lotNo        varchar(7),
    @waferId      varchar(3)
AS
BEGIN
    SET NOCOUNT ON;

    /* 1. 先尝试更新 */
    UPDATE dbo.Wafer_AOI_Process
    SET    Udt = GETDATE()
    WHERE  ProductModel = @productModel
      AND  LotNo        = @lotNo
      AND  Wafer        = @waferId;

    /* 2. 若无行受影响，则插入 */
    IF @@ROWCOUNT = 0
    BEGIN
        INSERT INTO dbo.Wafer_AOI_Process
               (ProductModel, LotNo, Wafer, Cdt, Udt)
        VALUES (@productModel, @lotNo, @waferId, GETDATE(), GETDATE());
    END
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[uspUpsertWaferAOIProcess] TO [Production]
    AS [dbo];

