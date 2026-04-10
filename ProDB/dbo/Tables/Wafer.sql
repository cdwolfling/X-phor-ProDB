CREATE TABLE [dbo].[Wafer] (
    [ID]                INT           IDENTITY (1, 1) NOT NULL,
    [Wafer号]            VARCHAR (50)  NOT NULL,
    [特殊备注]              VARCHAR (500) NULL,
    [测试数量]              INT           NULL,
    [测试通过数量bin1]        INT           NULL,
    [测试不良数量bin2]        INT           NULL,
    [划片不良数量bin23]       INT           NULL,
    [划片后sampling bin24] INT           NULL,
    [分拣不良数量bin25]       INT           NULL,
    [挑粒投入]              INT           NULL,
    [挑粒产出]              INT           NULL,
    [目检产出]              INT           NULL,
    [划片开始时间]            DATETIME      NULL,
    [划片结束时间]            DATETIME      NULL,
    [挑粒开始时间]            DATETIME      NULL,
    [挑粒结束时间]            DATETIME      NULL,
    [复判照片结束时间]          DATETIME      NULL,
    [OQC结束时间]           DATETIME      NULL,
    [包装结束时间]            DATETIME      NULL,
    [测试良率]              FLOAT (53)    NULL,
    [挑粒良率]              FLOAT (53)    NULL,
    [目检良率]              FLOAT (53)    NULL,
    [滚动良率]              FLOAT (53)    NULL,
    [目检结束时间]            DATETIME      NULL,
    [划痕HH]              INT           NULL,
    [扎痕ZH]              INT           NULL,
    [脏污ZW]              INT           NULL,
    [崩裂BL]              INT           NULL,
    [测试开始时间]            DATETIME      NULL,
    [测试结束时间]            DATETIME      NULL,
    [AOI开始]             DATETIME      NULL,
    [AOI结束]             DATETIME      NULL,
    [目检开始时间]            DATETIME      NULL,
    [复判照片开始时间]          DATETIME      NULL,
    [OQC开始时间]           DATETIME      NULL,
    [包装开始时间]            DATETIME      NULL,
    [pn]                VARCHAR (50)  NULL,
    [Lot号]              VARCHAR (50)  NULL,
    [Lead TIME]         FLOAT (53)    NULL,
    [复判-挑粒结束]           FLOAT (53)    NULL,
    [目检标准]              VARCHAR (200) NULL,
    [流程]                VARCHAR (200) NULL,
    [SourceName]        VARCHAR (200) NULL,
    [FileModifiedTime]  DATETIME      NULL,
    [更新日期]              DATETIME      NULL,
    [Cdt]               DATETIME      CONSTRAINT [DF_Wafer_Cdt] DEFAULT (getdate()) NULL,
    [Udt]               DATETIME      CONSTRAINT [DF_Wafer_Udt] DEFAULT (getdate()) NULL,
    [SourceDir]         VARCHAR (200) NULL,
    CONSTRAINT [PK_Wafer] PRIMARY KEY CLUSTERED ([ID] ASC)
);








GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Wafer_Wafer号]
    ON [dbo].[Wafer]([Wafer号] ASC);

