CREATE TABLE [dbo].[AOI_Json_ST] (
    [ID]               INT            IDENTITY (1, 1) NOT NULL,
    [ProductModel]     VARCHAR (8)    NULL,
    [LotNo]            VARCHAR (7)    NULL,
    [Wafer]            VARCHAR (3)    NULL,
    [TrayNo]           VARCHAR (2)    NULL,
    [JsonPath]         VARCHAR (1000) NULL,
    [FileModifiedTime] DATETIME       NULL,
    [Cdt]              DATETIME       CONSTRAINT [DF_AOI_Json_ST_Cdt] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_AOI_Json_ST] PRIMARY KEY CLUSTERED ([ID] ASC)
);




GO
GRANT UPDATE
    ON OBJECT::[dbo].[AOI_Json_ST] TO [Production]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[AOI_Json_ST] TO [Production]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[AOI_Json_ST] TO [Production]
    AS [dbo];


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_AOI_Json_ST_Unique]
    ON [dbo].[AOI_Json_ST]([ProductModel] ASC, [LotNo] ASC, [Wafer] ASC, [TrayNo] ASC);

