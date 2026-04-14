

/*
Created by Jackie Chen 2026-04-13 统计Wafer到达Layer层时，期望已经经过的LeadTime的汇总

select fab.[ufn_Get_Layer_ExpertedLT]('FAB2',1)
select fab.[ufn_Get_Layer_ExpertedLT]('FAB2',30)
select fab.[ufn_Get_Layer_ExpertedLT]('FAB3',30)
select fab.[ufn_Get_Layer_ExpertedLT]('FAB9',30)
*/
CREATE   FUNCTION [fab].[ufn_Get_Layer_ExpertedLT]
(
    @FAB varchar(50),
    @Layer INT
)
RETURNS INT
AS
BEGIN
    Declare @LT INT
    SELECT @LT=sum(lt.LeadTime) from fab.tFAB_LT lt where lt.FabName=@FAB and lt.Layer<@Layer

    RETURN ISNULL(@LT,0);
END