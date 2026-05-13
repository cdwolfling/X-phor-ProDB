
/*
select * from dbo.ufn_GetLabelViewShipDate('v_WH03_BOXLABEL')
select * from dbo.ufn_GetLabelViewShipDate('V_XH_BOXLABEL')
*/
CREATE   FUNCTION dbo.ufn_GetLabelViewShipDate
(
    @Label_View sysname
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        ConfigShipDate =
        (
            SELECT TOP (1)
                CAST(c.[Date] AS date)
            FROM dbo.Config_Label_View_Date c
            WHERE c.Label_View = @Label_View
              AND c.[Date] IS NOT NULL
            ORDER BY c.Udt DESC, c.ID DESC
        )
);