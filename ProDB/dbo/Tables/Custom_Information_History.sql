CREATE TABLE [dbo].[Custom_Information_History] (
    [History_ID]    BIGINT         IDENTITY (1, 1) NOT NULL,
    [CustomerID]    INT            NOT NULL,
    [Customer_Code] VARCHAR (50)   NULL,
    [Supplier_Code] VARCHAR (50)   NULL,
    [Material_PN]   VARCHAR (50)   NULL,
    [Dev_name]      NVARCHAR (15)  NULL,
    [PN]            VARCHAR (50)   NULL,
    [Description]   NVARCHAR (MAX) NULL,
    [UpdateUser]    [sysname]      DEFAULT (original_login()) NOT NULL,
    [UpdateDate]    DATETIME       DEFAULT (getdate()) NOT NULL,
    [UpdateHost]    VARCHAR (64)   DEFAULT (host_name()) NOT NULL,
    CONSTRAINT [PK_Custom_Information_History] PRIMARY KEY CLUSTERED ([History_ID] ASC)
);

