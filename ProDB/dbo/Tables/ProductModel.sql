CREATE TABLE [dbo].[ProductModel] (
    [ProductModel]       VARCHAR (20)   NOT NULL,
    [Retical_X]          INT            NULL,
    [Retical_Y]          INT            NULL,
    [Binmap_X]           INT            NULL,
    [Binmap_Y]           INT            NULL,
    [Box_X]              INT            NULL,
    [Box_Y]              INT            NULL,
    [Cdt]                DATETIME       CONSTRAINT [DF_ProductModel_Cdt] DEFAULT (getdate()) NULL,
    [txtBinmapFolder]    VARCHAR (1000) NULL,
    [txtBinmapFolder_V2] VARCHAR (1000) NULL,
    [Spec_ChannelNum]    INT            NULL,
    [Spec_impdNum]       INT            NULL,
    [Die_Qty]            INT            NULL,
    [Dev_name]           VARCHAR (20)   NULL,
    [CPFile_Suffix]      VARCHAR (20)   NULL,
    CONSTRAINT [PK_ProductModel] PRIMARY KEY CLUSTERED ([ProductModel] ASC)
);
















GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[ProductModel] TO [Production]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ProductModel] TO [Production]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ProductModel] TO [Production]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ProductModel] TO [SpecMaintainer]
    AS [dbo];

