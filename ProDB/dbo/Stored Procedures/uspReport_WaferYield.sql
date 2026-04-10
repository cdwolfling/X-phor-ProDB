/*
2026-02-28 Jackie Chen
@ProductStatus:
1 已测试未划片
2 已划片
3 已完成
exec uspReport_WaferYield @ProductModel='Coral3p1',@ProductStatus=2,@LotList=null

Change Log:
*/
CREATE     PROC [dbo].[uspReport_WaferYield]
(
@ProductModel varchar(20),
@ProductStatus INT,
@LotList varchar(MAX)=''
)
AS
BEGIN
    SET NOCOUNT ON;
    
	select @LotList=isnull(@LotList,'')
    select @LotList=replace(@LotList,char(13),',')
    select @LotList=replace(@LotList,char(10),',')
	IF OBJECT_ID('tempdb..#WaferList') IS NOT NULL DROP TABLE #WaferList
	create table #WaferList(Wafer varchar(20))
	if @LotList<>''
	begin
		insert #WaferList(Wafer)
			select distinct w.Wafer号
			from dbo.ufnGetListFromSourceString(@LotList,',') f
            join dbo.Wafer w on f.MyColumn=w.Lot号
            where f.MyColumn<>''
	end
	else
	begin
        if @ProductStatus=1
        begin
		    insert #WaferList(Wafer)
			    select distinct s.Wafer号
			    from dbo.Wafer s
			    where left(s.SourceName,8) = @ProductModel
                and s.测试结束时间>='2024-01-01'
                and (s.划片结束时间 is null or s.划片结束时间 = '1899-12-31')
        end
        else if @ProductStatus=2
        begin
		    insert #WaferList(Wafer)
			select distinct s.Wafer号
			from dbo.Wafer s
			where left(s.SourceName,8) = @ProductModel
            and s.划片结束时间>='2024-01-01'
            and (s.包装结束时间 is null or s.包装结束时间 = '1899-12-31')
        end
        else if @ProductStatus=3
        begin
		    insert #WaferList(Wafer)
			select distinct s.Wafer号
			from dbo.Wafer s
			where left(s.SourceName,8) = @ProductModel
            and s.包装结束时间>='2024-01-01'
        end
	end
    
    SELECT
        w.*,
        ISNULL(x.Bin7, 0) AS DS_Bin7,
        ISNULL(x.Bin8, 0) AS DS_Bin8
    FROM dbo.Wafer w
    join #WaferList l on w.Wafer号=l.Wafer
    LEFT JOIN (
        SELECT
            d.LotWafer,
            SUM(CASE WHEN d.bin = 7 THEN 1 ELSE 0 END) AS Bin7,
            SUM(CASE WHEN d.bin = 8 THEN 1 ELSE 0 END) AS Bin8
        FROM dbo.Die d
        WHERE d.bin IN (7, 8)
        GROUP BY d.LotWafer
    ) x
        ON x.LotWafer = w.[Wafer号];


END