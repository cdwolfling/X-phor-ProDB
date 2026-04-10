CREATE TABLE [dbo].[AOI_Json_RI] (
    [ID]               INT            IDENTITY (1, 1) NOT NULL,
    [ProductModel]     VARCHAR (20)   NULL,
    [LotNo]            VARCHAR (7)    NULL,
    [Wafer]            VARCHAR (3)    NULL,
    [TrayNo]           VARCHAR (2)    NULL,
    [JsonPath]         VARCHAR (1000) NULL,
    [FileModifiedTime] DATETIME       NULL,
    [Cdt]              DATETIME       CONSTRAINT [DF_AOI_Json_RI_Cdt] DEFAULT (getdate()) NULL,
    [Udt]              DATETIME       CONSTRAINT [DF_AOI_Json_RI_Udt] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_AOI_Json_RI] PRIMARY KEY CLUSTERED ([ID] ASC)
);








GO
GRANT UPDATE
    ON OBJECT::[dbo].[AOI_Json_RI] TO [Production]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[AOI_Json_RI] TO [Production]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[AOI_Json_RI] TO [Production]
    AS [dbo];


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_AOI_Json_RI_Unique]
    ON [dbo].[AOI_Json_RI]([ProductModel] ASC, [LotNo] ASC, [Wafer] ASC, [TrayNo] ASC);

