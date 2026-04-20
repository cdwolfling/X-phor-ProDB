CREATE TABLE [dbo].[Config_Ship_InsertionLoss_Customer] (
    [CustomerID]       INT           IDENTITY (1, 1) NOT NULL,
    [Customer_Code]    VARCHAR (50)  NULL,
    [ShippingDataPath] VARCHAR (200) NULL,
    [Cdt]              DATETIME      CONSTRAINT [DF_Config_Ship_InsertionLoss_Customer_Cdt] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_Config_Ship_InsertionLoss_Customer] PRIMARY KEY CLUSTERED ([CustomerID] ASC)
);

