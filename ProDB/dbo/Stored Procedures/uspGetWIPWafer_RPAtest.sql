

/*
-- =============================================
-- Author:		Jackie Chen
-- Create date: 2025/12/2
-- Description:	Get WIP Wafer, It's used in 4. 数据库报表.xlsx, is also used in Yield_基于数据库报表.xlsm(RPA project)
-- Notes:

Change Log:
2026-03-02 JC: 造数据LN38999-05/15/25  LN41275-05/15/25
2026-02-11 JC: 造数据, 测试IN工单的完工申报
2026-02-10 JC: 造数据, 测试IN工单的完工申报
2025-12-11 JC: 造数据, 5个CP, 5个IN
-- =============================================
*/
CREATE PROCEDURE [dbo].[uspGetWIPWafer_RPAtest]
AS
BEGIN
    SET NOCOUNT ON;
    
    if OBJECT_ID('tempdb..#Wafer') is not null drop table #Wafer
    select w.* into #Wafer
        from Wafer w
        --left join (select Lotid_Wafer,sum(Ship_Qty) as Ship_Qty from Shipping_list sh group by Lotid_Wafer) g
        --on w.Wafer号=g.Lotid_Wafer and g.Ship_Qty>=w.目检产出
        where 1=2
        or w.Wafer号 IN ( 'LN38999-W05','LN38999-W15','LN38999-W25')
        or w.Wafer号 IN ( 'LN41275-W05','LN41275-W15','LN41275-W25')

    --1. 测试CP工单的完工申报功能：
    --update z set 复判照片结束时间=NULL--, 测试结束时间=getdate()
    --    from #Wafer z
    --2. 测试IN工单的完工申报功能：
    update z set 测试结束时间=NULL--, 复判照片结束时间=getdate()
        from #Wafer z
        --where Wafer号 in ('LN42466')
                
    --update z set z.[测试通过数量bin1]= z.[测试通过数量bin1] - z.[划片后sampling bin24]
    --    ,z.[测试不良数量bin2]= z.[测试不良数量bin2] + z.[划片后sampling bin24]
    --    from #Wafer z

    select z.ID, z.Lot号, z.Wafer号
        , z.测试开始时间 , z.测试结束时间, z.测试通过数量bin1, z.测试不良数量bin2, z.[划片后sampling bin24]
        , z.划片开始时间, z.划片结束时间, z.挑粒开始时间, z.挑粒结束时间, z.挑粒投入, z.挑粒产出, z.复判照片开始时间, z.复判照片结束时间, z.目检产出
        , left(z.SourceName, 8) as 产品族
        , case when left(z.SourceName, 8)='CORAL3P1' then convert(char(4),year(getdate()))+'年汇总'
            else Replace(left(lower(z.SourceName), 8), 'P', '.')
            end as ERP录入梳理Sheet
        from #Wafer z
        order by 产品族, z.Lot号, z.Wafer号
END;