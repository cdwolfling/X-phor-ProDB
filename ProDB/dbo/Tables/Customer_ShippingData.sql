CREATE TABLE [dbo].[Customer_ShippingData] (
    [CustomerID]       INT           IDENTITY (1, 1) NOT NULL,
    [Customer_Code]    VARCHAR (50)  NULL,
    [ShippingDataPath] VARCHAR (200) NULL,
    [Cdt]              DATETIME      CONSTRAINT [DF_Customer_ShippingData_Cdt] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_CCustomer_ShippingData] PRIMARY KEY CLUSTERED ([CustomerID] ASC)
);

