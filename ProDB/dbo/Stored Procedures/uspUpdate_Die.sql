


/*
-- =============================================
-- Author:		Jackie Chen
-- Create date: 2025/11/28
-- Description:	Refer Z_Die, Update Die
-- Notes:

Change Log:
-- =============================================
*/
CREATE PROCEDURE [dbo].[uspUpdate_Die]
AS
BEGIN
    SET NOCOUNT ON;

	IF EXISTS(SELECT 1 FROM dbo.Z_Die AS z LEFT JOIN dbo.Die d ON z.LotWafer=d.LotWafer WHERE d.LotWafer IS NULL)
	BEGIN
		INSERT dbo.Die(LotWafer, Seqid, Cbin)
			SELECT z.LotWafer, z.Seqid, z.Cbin
			FROM dbo.Z_Die AS z
			LEFT JOIN dbo.Die d ON z.LotWafer=d.LotWafer
			WHERE d.LotWafer IS NULL			
	END
END;
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[uspUpdate_Die] TO [Production]
    AS [dbo];

