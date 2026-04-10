CREATE TABLE [dbo].[Z_Shipping_list] (
    [Project]          VARCHAR (15) NOT NULL,
    [Ship_Type]        VARCHAR (15) NULL,
    [PN]               VARCHAR (50) NOT NULL,
    [Ship_date]        DATE         NULL,
    [Customer_Code]    VARCHAR (15) NULL,
    [PO]               VARCHAR (25) NULL,
    [PO_End]           VARCHAR (25) NULL,
    [Carton_ID_Inner]  VARCHAR (15) NULL,
    [Carton_ID_Outter] VARCHAR (15) NULL,
    [Lot_Wafer_Box_ID] VARCHAR (15) NULL,
    [Lotid_Wafer]      VARCHAR (15) NULL,
    [Ship_Qty]         INT          NULL,
    [TrayLastSN]       VARCHAR (20) NULL,
    [Package_Type]     VARCHAR (15) NULL,
    [Lot_ID]           VARCHAR (15) NULL,
    [Wafer_ID]         VARCHAR (15) NULL,
    [Box_ID]           VARCHAR (15) NULL
);




GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_Z_Shipping_list_Lot_Wafer_Box_ID]
    ON [dbo].[Z_Shipping_list]([Lot_Wafer_Box_ID] ASC);


GO

GRANT ALTER
    ON OBJECT::[dbo].[Z_Shipping_list] TO [Production]
    AS [dbo];
GO

GRANT INSERT
    ON OBJECT::[dbo].[Z_Shipping_list] TO [Production]
    AS [dbo];
GO

GRANT SELECT
    ON OBJECT::[dbo].[Z_Shipping_list] TO [Production]
    AS [dbo];
GO

