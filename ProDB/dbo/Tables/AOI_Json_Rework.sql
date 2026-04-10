CREATE TABLE [dbo].[AOI_Json_Rework] (
    [ID]               INT            IDENTITY (1, 1) NOT NULL,
    [ProductModel]     VARCHAR (8)    NULL,
    [LotNo]            VARCHAR (7)    NULL,
    [Wafer]            VARCHAR (3)    NULL,
    [TrayNo]           VARCHAR (2)    NULL,
    [JsonPath]         VARCHAR (1000) NULL,
    [FileModifiedTime] DATETIME       NULL,
    [Cdt]              DATETIME       CONSTRAINT [DF_AOI_Json_Rework_Cdt] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_AOI_Json_Rework] PRIMARY KEY CLUSTERED ([ID] ASC)
);

