/*
-- =============================================
-- Author:		Jackie Chen
-- Create date: 2026/1/25
-- Description:	获取待处理CP数据的Wafer清单
-- Notes:

Change Log:
2026-02-12 JC: 增加Weight & TimeFlag， 优先处理已出货的产品； 优先处理最近包装或最近出货的产品
2026-01-28 JC: 增加Wafer选取范围：包装结束时间 or 包装开始时间 or dbo.Shipping_list
2026-01-27 JC: 条件改成：存在 w.测试结束时间 且 之前未处理过
2026-01-26 JC: 条件改成：OQC结束 或者 已出货, 11 wafer 无测试汇总文件 ('LN74796-W18','LN74796-W22','LN34368-W16','LN34368-W17','LN34368-W18','LN34368-W19','LN34368-W21','LN34368-W22','LN34368-W23','LN34368-W24','LN41687-W02')
2026-01-26 JC: 需求清单从HK02客户的2个月， 扩展到Coral3p1/Coral6p0的所有完成OQC的产品
-- =============================================
*/
CREATE PROCEDURE [dbo].[uspGetWaferList_ToHandlingCPData]
AS
BEGIN
    SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#WaferList') IS NOT NULL DROP TABLE #WaferList
	create table #WaferList(ProductModel varchar(8),LotWafer varchar(11), Weight int, TimeFlag datetime)
	insert #WaferList(ProductModel, LotWafer,Weight, TimeFlag)
		select left(w.SourceName,8), w.Wafer号, 2, w.测试结束时间
		from dbo.Wafer w
		left join dbo.CPTest_File f on w.Wafer号=f.LotWafer and isnull(w.测试结束时间,'1899-12-30')=isnull(f.CPTest_TrackOutTime,'1899-12-30')
		where (w.测试结束时间>='2000/1/1' or w.OQC结束时间>='2000/1/1' or w.包装结束时间>='2000/1/1' or w.包装开始时间>='2000/1/1')
		and f.FileId is null
		union
		select replace(Project,'.','p'), s.Lotid_Wafer, 1, max(s.Ship_date)
		from dbo.Shipping_list s
		left join dbo.CPTest_File f on s.Lotid_Wafer=f.LotWafer
		where f.LotWafer is null and s.Lotid_Wafer not like '%BIN%'
		group by s.Project, s.Lotid_Wafer

	select top 100 z.ProductModel, z.LotWafer, z.Weight, z.TimeFlag
		from #WaferList z
		order by z.Weight, z.TimeFlag desc, z.ProductModel, z.LotWafer

END;