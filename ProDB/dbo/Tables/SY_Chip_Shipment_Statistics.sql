CREATE TABLE [dbo].[SY_Chip_Shipment_Statistics] (
    [Seqid]  INT          IDENTITY (1, 1) NOT NULL,
    [序号]     INT          NULL,
    [项目号]    VARCHAR (10) NULL,
    [出货类别]   VARCHAR (10) NULL,
    [产品名称]   VARCHAR (50) NULL,
    [发货日期]   DATE         NULL,
    [客户名称]   VARCHAR (10) NULL,
    [订单号]    VARCHAR (50) NULL,
    [快递单号]   VARCHAR (20) NULL,
    [包装-外箱号] VARCHAR (20) NULL,
    [包装-内箱号] VARCHAR (20) NULL,
    [盘号]     VARCHAR (20) NULL,
    [wafer号] VARCHAR (20) NULL,
    [数量]     INT          NULL,
    [产品尾号]   VARCHAR (20) NULL,
    [包装方式]   VARCHAR (50) NULL,
    [Cdt]    DATETIME     CONSTRAINT [DF_SY_Chip_Shipment_Statistics_Cdt] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_SY_Chip_Shipment_Statistics] PRIMARY KEY CLUSTERED ([Seqid] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_SY_Chip_Shipment_Statistics_盘号]
    ON [dbo].[SY_Chip_Shipment_Statistics]([盘号] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_SY_Chip_Shipment_Statistics_wafer号]
    ON [dbo].[SY_Chip_Shipment_Statistics]([wafer号] ASC);

