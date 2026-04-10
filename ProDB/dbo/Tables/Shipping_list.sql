CREATE TABLE [dbo].[Shipping_list] (
    [Shipping_list_ID]         INT          IDENTITY (1, 1) NOT NULL,
    [Site]                     VARCHAR (2)  NOT NULL,
    [Project]                  VARCHAR (15) NULL,
    [Ship_Type]                VARCHAR (15) NULL,
    [PN]                       VARCHAR (50) NOT NULL,
    [Ship_date]                DATE         NULL,
    [Customer_Code]            VARCHAR (15) NOT NULL,
    [PO]                       VARCHAR (25) NULL,
    [PO_End]                   VARCHAR (25) NULL,
    [Carton_ID_Inner]          VARCHAR (15) NULL,
    [Carton_ID_Outter]         VARCHAR (15) NULL,
    [Lot_Wafer_Box_ID]         VARCHAR (15) NOT NULL,
    [Lotid_Wafer]              VARCHAR (15) NULL,
    [Ship_Qty]                 INT          NULL,
    [TrayLastSN]               VARCHAR (20) NULL,
    [Package_Type]             VARCHAR (15) NULL,
    [Lot_ID]                   VARCHAR (15) NULL,
    [Wafer_ID]                 VARCHAR (15) NULL,
    [Box_ID]                   VARCHAR (15) NULL,
    [TrackingNumber]           VARCHAR (50) NULL,
    [OEM_Ship_date]            DATE         NULL,
    [Cdt]                      DATETIME     CONSTRAINT [DF_Shipping_list_Cdt] DEFAULT (getdate()) NULL,
    [Udt]                      DATETIME     CONSTRAINT [DF_Shipping_list_Udt] DEFAULT (getdate()) NULL,
    [GenerateShippingData_Cdt] DATETIME     NULL,
    [ImportTraySN_Cdt]         DATETIME     NULL,
    CONSTRAINT [PK_Shipping_list] PRIMARY KEY CLUSTERED ([Shipping_list_ID] ASC)
);






















GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Shipping_list_Lot_Wafer_Box_ID]
    ON [dbo].[Shipping_list]([Lot_Wafer_Box_ID] ASC);




GO
GRANT UPDATE
    ON OBJECT::[dbo].[Shipping_list] TO [Production1]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[Shipping_list] TO [Production]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[Shipping_list] TO [Production1]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[Shipping_list] TO [Production]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[Shipping_list] TO [Production1]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[Shipping_list] TO [Production]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[Shipping_list] TO [Production1]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[Shipping_list] TO [Production]
    AS [dbo];


GO
/*
Change Log:
2026-02-07 JC: Add Site/TrackingNumber/OEM_Ship_date column; ignore the update of Cdt/Udt/..
2026-01-29 JC: Add GenerateShippingData_Cdt, Udt
2026-01-21 JC: Add TrayLastSN & Cdt
*/
CREATE TRIGGER [dbo].[trg_Shipping_list_Update]
ON [dbo].[Shipping_list]
AFTER UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    /* ========= DELETE：一律写历史 ========= */
    IF NOT EXISTS (SELECT 1 FROM inserted)
    BEGIN
        INSERT INTO dbo.Shipping_list_History
               (Shipping_list_ID, Site, Project, Ship_Type, PN, Ship_date,
                Customer_Code, PO, PO_End, Carton_ID_Inner, Carton_ID_Outter,
                Lot_Wafer_Box_ID, Lotid_Wafer, Ship_Qty, TrayLastSN, Package_Type,
                Lot_ID, Wafer_ID, Box_ID, TrackingNumber, OEM_Ship_date, Cdt, Udt, GenerateShippingData_Cdt, ImportTraySN_Cdt)
        SELECT Shipping_list_ID, Site, Project, Ship_Type, PN, Ship_date,
               Customer_Code, PO, PO_End, Carton_ID_Inner, Carton_ID_Outter,
               Lot_Wafer_Box_ID, Lotid_Wafer, Ship_Qty, TrayLastSN, Package_Type,
               Lot_ID, Wafer_ID, Box_ID, TrackingNumber, OEM_Ship_date, Cdt, Udt, GenerateShippingData_Cdt, ImportTraySN_Cdt
        FROM deleted;

        RETURN;
    END

    /* ========= UPDATE：仅当“非(GenerateShippingData_Cdt/ImportTraySN_Cdt/Udt)”字段变化才写历史 ========= */
    IF EXISTS
    (
        SELECT 1
        FROM inserted i
        INNER JOIN deleted d
            ON i.Shipping_list_ID = d.Shipping_list_ID
        WHERE
            /* 下面这些列：只要任意一列新旧不同，就认为是“有效变更”，需要写历史 */
            ISNULL(i.Site,'') <> ISNULL(d.Site,'')
            OR ISNULL(i.Project,'') <> ISNULL(d.Project,'')
            OR ISNULL(i.Ship_Type,'') <> ISNULL(d.Ship_Type,'')
            OR ISNULL(i.PN,'') <> ISNULL(d.PN,'')
            OR ISNULL(CONVERT(datetime2(0), i.Ship_date), '19000101') <> ISNULL(CONVERT(datetime2(0), d.Ship_date), '19000101')
            OR ISNULL(i.Customer_Code,'') <> ISNULL(d.Customer_Code,'')
            OR ISNULL(i.PO,'') <> ISNULL(d.PO,'')
            OR ISNULL(i.PO_End,'') <> ISNULL(d.PO_End,'')
            OR ISNULL(i.Carton_ID_Inner,'') <> ISNULL(d.Carton_ID_Inner,'')
            OR ISNULL(i.Carton_ID_Outter,'') <> ISNULL(d.Carton_ID_Outter,'')
            OR ISNULL(i.Lot_Wafer_Box_ID,'') <> ISNULL(d.Lot_Wafer_Box_ID,'')
            OR ISNULL(i.Lotid_Wafer,'') <> ISNULL(d.Lotid_Wafer,'')
            OR ISNULL(i.Ship_Qty, 0) <> ISNULL(d.Ship_Qty, 0)
            OR ISNULL(i.TrayLastSN,'') <> ISNULL(d.TrayLastSN,'')
            OR ISNULL(i.Package_Type,'') <> ISNULL(d.Package_Type,'')
            OR ISNULL(i.Lot_ID,'') <> ISNULL(d.Lot_ID,'')
            OR ISNULL(i.Wafer_ID,'') <> ISNULL(d.Wafer_ID,'')
            OR ISNULL(i.Box_ID,'') <> ISNULL(d.Box_ID,'')
            OR ISNULL(i.TrackingNumber,'') <> ISNULL(d.TrackingNumber,'')
            OR ISNULL(CONVERT(datetime2(0), i.OEM_Ship_date), '19000101') <> ISNULL(CONVERT(datetime2(0), d.OEM_Ship_date), '19000101')
    )
    BEGIN
        INSERT INTO dbo.Shipping_list_History
               (Shipping_list_ID, Site, Project, Ship_Type, PN, Ship_date,
                Customer_Code, PO, PO_End, Carton_ID_Inner, Carton_ID_Outter,
                Lot_Wafer_Box_ID, Lotid_Wafer, Ship_Qty, TrayLastSN, Package_Type,
                Lot_ID, Wafer_ID, Box_ID, TrackingNumber, OEM_Ship_date, Cdt, Udt, GenerateShippingData_Cdt, ImportTraySN_Cdt)
        SELECT Shipping_list_ID, Site, Project, Ship_Type, PN, Ship_date,
               Customer_Code, PO, PO_End, Carton_ID_Inner, Carton_ID_Outter,
               Lot_Wafer_Box_ID, Lotid_Wafer, Ship_Qty, TrayLastSN, Package_Type,
               Lot_ID, Wafer_ID, Box_ID, TrackingNumber, OEM_Ship_date, Cdt, Udt, GenerateShippingData_Cdt, ImportTraySN_Cdt
        FROM deleted;
    END
END
GO
CREATE NONCLUSTERED INDEX [IX_Shipping_list_Ship_date_Customer_Code]
    ON [dbo].[Shipping_list]([Ship_date] ASC, [Customer_Code] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Shipping_list_Site_Lot_Wafer_Box_ID]
    ON [dbo].[Shipping_list]([Site] ASC, [Lot_Wafer_Box_ID] ASC);

