/*
Create by Jackiech on 2026-04-02

SELECT mean, std FROM dbo.ufn_GetUEC_Mean_Std('LN41477-W01')

Change Log:
2026-04-04 JC: Add " AND v.isRecent=1"; Add outpt CPFileTime
*/
CREATE   FUNCTION [dbo].[ufn_GetUEC_Mean_Std](@LotWafer NVARCHAR(50))
RETURNS TABLE
AS
RETURN (
    SELECT AVG(v.UEC_Onchip) AS mean, STDEVP(v.UEC_Onchip) AS std, max(v.FileModifiedTime) as CPFileTime
    FROM dbo.vw_CPTestData v
    WHERE v.LotWafer = @LotWafer AND v.isRecent=1
)