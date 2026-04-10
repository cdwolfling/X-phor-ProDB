
/*
-- =============================================
-- Author:		Jackie Chen
-- Create date: 2025/12/2
-- Description:	Get WIP Wafer, It's used in 4. 数据库报表.xlsx, is also used in Yield_基于数据库报表.xlsm(RPA project)
-- Notes:

Change Log:
2026-03-26 JC: cp录入测试lot  3.1  LN47432-W01~W25   6.0 LN46185-W01~W25
2026-03-20 JC: IN完工LN44566-W06/W07/W17   LN45037-W22
2026-03-18 JC: IN完工申报功能转试运行， Wafer：LN44793-07/20/24-->LN45037-01/07/18
2026-03-04 JC: IN完工申报功能转试运行， Wafer：LN44796-01/03/04/05/15/25
2026-01-16 JC: 修改RPA录入Lot的测试数据范围, 改为LN41476和41478, 41476比昨天少W16/W18
2026-01-15 JC: "ERP录入梳理Sheet"改为小写，以兼容影刀RPA； 修改RPA录入Lot的测试数据范围, 改为 Coral4.1
    4.1   LN38071-W01~W25(共25片）
    4.1   LN41476-W01~W04/W06~W18/W20~W22/W24~W25(共22片）
    4.1   LN41478-W01~W10/W20~W25(共16片）
    3.1   LN44130-W01~W25（25片）--除了第5片和第10片
2026-01-14 JC: 修改RPA录入Lot的测试数据范围, 改为 LN42657-W01~W16/W18~W25 
2026-01-13 JC: 增加输出栏位 ERP录入梳理Sheet
2026-01-12 JC: 修改RPA录入Lot的测试数据范围, 改为 LN44793-W05~W21/W24~W25; 
2026-01-09 JC: 修改RPA录入Lot的测试数据范围, 改为 LN44567-W12/W13/W14/W17   LN44793-W01~W04/W22~W24; 改为 LN42657-W01~08; 
2026-01-07 JC: 修改RPA录入Lot的测试数据范围, 改为 LN44567-W04/W06~11/W16/W18~22  --> 第一次系统接受RPA的录入数据
2026-01-06 JC: 修改RPA录入Lot的测试数据范围, 改为 LN44346-W16/W19/W20/W22/W23
2025-12-18 JC: 修改RPA录入Lot的测试数据范围, 改为 LN42894-W08/W13/W14/W16/W18/W21/W22
2025-12-14 JC: 修改RPA录入Lot的测试数据范围, 改为 LN42893 W12~W15、W17~25, 取消 z.[测试通过数量bin1] z.[测试不良数量bin2]的重计算逻辑
2025-12-14 JC: 修改RPA录入Lot的测试数据范围, 从LN42164 改为 LN44568
2025-12-12 JC: 录入ERP的Bin数量调整:
    录入ERP的Bin1（半成品）=Yield的“测试通过数量bin1”- Yield的“划片后sampling bin24”
    录入ERP的Bin2（废品仓）=Yield的“测试不良数量bin2”+ Yield的“划片后sampling bin24”
-- =============================================
*/
CREATE PROCEDURE [dbo].[uspGetWIPWafer]
AS
BEGIN
    SET NOCOUNT ON;
    
    if OBJECT_ID('tempdb..#Wafer') is not null drop table #Wafer
    select w.* into #Wafer
        from Wafer w
        --left join (select Lotid_Wafer,sum(Ship_Qty) as Ship_Qty from Shipping_list sh group by Lotid_Wafer) g
        --on w.Wafer号=g.Lotid_Wafer and g.Ship_Qty>=w.目检产出
        where 1=2
        or w.Wafer号 between 'LN47432-W01' and 'LN47432-W25'
        or w.Wafer号 between 'LN46185-W01' and 'LN46185-W25'

    --1. 测试CP工单的完工申报功能：
    update z set z.复判照片结束时间=NULL
        from #Wafer z
        where z.测试结束时间>='2024/1/1'
        and (z.复判照片结束时间 is null or z.复判照片结束时间='1899-12-31')
    --2. 测试IN工单的完工申报功能：
    update z set 测试结束时间=NULL
        from #Wafer z
        where z.复判照片结束时间>='2024/1/1'

    select z.ID, z.Lot号, z.Wafer号
        , z.测试开始时间, z.测试结束时间, z.测试通过数量bin1, z.测试不良数量bin2, z.[划片后sampling bin24]
        , z.划片开始时间, z.划片结束时间, z.挑粒开始时间, z.挑粒结束时间, z.挑粒投入, z.挑粒产出, z.复判照片开始时间, z.复判照片结束时间, z.目检产出
        , left(z.SourceName, 8) as 产品族
        , case when left(z.SourceName, 8)='CORAL3P1' then convert(char(4),year(getdate()))+'年汇总'
            else Replace(left(lower(z.SourceName), 8), 'P', '.')
            end as ERP录入梳理Sheet
        from #Wafer z
        order by 产品族, z.Lot号, z.Wafer号

END;
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[uspGetWIPWafer] TO [Production]
    AS [dbo];

