CREATE TABLE [dbo].[Config_Ship_InsertionLoss_ProductModel] (
    [ProductModelID] INT          IDENTITY (1, 1) NOT NULL,
    [ProductModel]   VARCHAR (20) NULL,
    [Cdt]            DATETIME     CONSTRAINT [DF_Config_Ship_InsertionLoss_ProductModel_Cdt] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_Config_Ship_InsertionLoss_ProductModel] PRIMARY KEY CLUSTERED ([ProductModelID] ASC)
);

