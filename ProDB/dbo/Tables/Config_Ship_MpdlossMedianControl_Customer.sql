CREATE TABLE [dbo].[Config_Ship_MpdlossMedianControl_Customer] (
    [ID]            INT          IDENTITY (1, 1) NOT NULL,
    [Customer_Code] VARCHAR (50) NULL,
    [ProductFamily] VARCHAR (20) NULL,
    [Cdt]           DATETIME     CONSTRAINT [DF_Config_Ship_MpdlossMedianControl_Customer_Cdt] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_Config_Ship_MpdlossMedianControl_Customer] PRIMARY KEY CLUSTERED ([ID] ASC)
);

