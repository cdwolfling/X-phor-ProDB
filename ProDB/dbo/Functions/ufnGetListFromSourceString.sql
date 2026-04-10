

/*
Jackie 20251121
select charindex('/','1/2')  --2
select STUFF('12345',3,2,'Replaced')  --12Replaced5
select * from dbo.ufnGetListFromSourceString('DC//DMC///FL','//') --DC & DMC & /FL
select * from dbo.ufnGetListFromSourceString(N'SO111975 - Keyence Corporation - 372-13007659-01',' - ')
--SO111975
-- Keyence Corporation
-- 372-13007659-01

change log:
*/
CREATE FUNCTION [dbo].[ufnGetListFromSourceString]
(
	@Source nvarchar(max),
	@SpitFlag nvarchar(max)
)
RETURNS @rtnTable TABLE (SeqId int identity(1,1) not null,MyColumn nvarchar(max))
AS
Begin
	declare @intPosition int
	select @intPosition=charindex(@SpitFlag,@Source)
	while @intPosition>0
	begin
		insert @rtnTable(MyColumn) values(substring(@Source,1,@intPosition-1))
		select @Source=STUFF(@Source,1,@intPosition-1+LEN(@SpitFlag),'')
		select @intPosition=charindex(@SpitFlag,@Source)
	end
	insert @rtnTable(MyColumn) values(@Source)
	return
end
