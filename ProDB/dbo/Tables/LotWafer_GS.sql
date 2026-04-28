CREATE TABLE [dbo].[LotWafer_GS] (
    [ID]           INT          IDENTITY (1, 1) NOT NULL,
    [ProductModel] VARCHAR (50) NULL,
    [LotWafer]     VARCHAR (20) NULL,
    [Cdt]          DATETIME     CONSTRAINT [DF_LotWafer_GS_Cdt] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_LotWafer_GS] PRIMARY KEY CLUSTERED ([ID] ASC)
);

