CREATE TABLE [dbo].[AOI_Json_RI_Data] (
    [ID]           INT           IDENTITY (1, 1) NOT NULL,
    [jsonRiId]     INT           NULL,
    [BinInfo]      VARCHAR (50)  NULL,
    [ChipType]     VARCHAR (10)  NULL,
    [GChipType]    VARCHAR (10)  NULL,
    [ColPos]       INT           NULL,
    [GImagePath]   VARCHAR (200) NULL,
    [GImagePath_2] VARCHAR (200) NULL,
    [Name]         VARCHAR (200) NULL,
    [RowPos]       INT           NULL,
    [WaferInfo]    VARCHAR (50)  NULL,
    [YImagePath]   VARCHAR (200) NULL,
    [YImagePath_2] VARCHAR (200) NULL,
    [GName]        VARCHAR (50)  NULL,
    [ImageReaded]  BIT           NULL,
    [GImageReaded] BIT           NULL,
    CONSTRAINT [PK_AOI_Json_RI_Data] PRIMARY KEY CLUSTERED ([ID] ASC)
);




GO
GRANT UPDATE
    ON OBJECT::[dbo].[AOI_Json_RI_Data] TO [Production]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[AOI_Json_RI_Data] TO [Production]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[AOI_Json_RI_Data] TO [Production]
    AS [dbo];

