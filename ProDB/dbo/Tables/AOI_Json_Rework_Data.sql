CREATE TABLE [dbo].[AOI_Json_Rework_Data] (
    [ID]           INT          IDENTITY (1, 1) NOT NULL,
    [jsonReworkId] INT          NULL,
    [WaferID]      VARCHAR (50) NULL,
    [LoadPos]      VARCHAR (10) NULL,
    [chipRegPos]   VARCHAR (10) NULL,
    [Name]         VARCHAR (50) NULL,
    [TrayKey]      VARCHAR (50) NULL,
    [TrayID]       VARCHAR (50) NULL,
    [TrayIndex]    INT          NULL,
    [UnLoadPos]    VARCHAR (10) NULL,
    [Bin]          VARCHAR (2)  NULL,
    [AOIResult]    VARCHAR (2)  NULL,
    [GAOIResult]   VARCHAR (2)  NULL,
    CONSTRAINT [PK_AOI_Json_Rework_Data] PRIMARY KEY CLUSTERED ([ID] ASC)
);

