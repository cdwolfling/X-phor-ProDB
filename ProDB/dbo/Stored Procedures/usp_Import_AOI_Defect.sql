/*
================================================================================
存储过程名称: dbo.usp_Import_AOI_Defect
用途: 导入AOI图片文件路径及修改时间到数据库
exec [dbo].[usp_Import_AOI_Defect] @jpgPath='6.0LN41686-W05_BIN1-02AOI2#_1_1.jpg'
    ,@jpgModifiedDatetime='2025/12/21 5:01'
    ,@GjpgPath='6.0LN41686-W05_BIN1-02AOI2#_1_1.jpg'
    ,@GjpgModifiedDatetime='2025/12/21 5:01'
select * from [dbo].[Die_AOIPicked] d where d.DieID=157866

Change Log:
2025-12-22 JC: Initial
================================================================================
*/
CREATE PROCEDURE [dbo].[usp_Import_AOI_Defect](
    @jpgPath varchar(1000),
    @jpgModifiedDatetime datetime=null,
    @GjpgPath varchar(1000)=null,
    @GjpgModifiedDatetime datetime=null
)
AS
BEGIN
    SET NOCOUNT ON;

    declare @LotWafer varchar(100), @BoxNo int, @AOI_name varchar(5)
    declare @tmp varchar(1000)
    declare @Bin_Box_AOI varchar(1000)
    select @tmp=substring(@jpgPath,4,len(@jpgPath))
    select @tmp=REPLACE(@tmp,'.jpg','')
    select @LotWafer=f.MyColumn from dbo.ufnGetListFromSourceString(@tmp,'_') f where f.SeqId=1
    select @Bin_Box_AOI=f.MyColumn from dbo.ufnGetListFromSourceString(@tmp,'_') f where f.SeqId=2
    select @BoxNo=SUBSTRING(@Bin_Box_AOI,6,2)
    select @AOI_name=f.MyColumn from dbo.ufnGetListFromSourceString(@tmp,'_') f where f.SeqId=3
    select @AOI_name=@AOI_name+'_'+f.MyColumn from dbo.ufnGetListFromSourceString(@tmp,'_') f where f.SeqId=4
    
    declare @DieID INT
    select @DieID=DieID from dbo.Die d where LotWafer=@LotWafer and BoxNo=@BoxNo and AOI_name=@AOI_name
    print @DieID

    if @jpgModifiedDatetime is not null
        update p set p.jpgPath=@jpgPath, p.jpgModifieddatetime=@jpgModifiedDatetime, p.GjpgPath=@GjpgPath, p.GjpgModifieddatetime=@GjpgModifiedDatetime,Udt=GETDATE()
            from [dbo].[Die_AOIPicked] p
            where p.DieID=@DieID
    else--此时@jpgPath至负责帮忙找到@DieID
        update p set p.jpgPath=null, p.jpgModifieddatetime=null, p.GjpgPath=null, p.GjpgModifieddatetime=null,Udt=GETDATE()
            from [dbo].[Die_AOIPicked] p
            where p.DieID=@DieID

END;