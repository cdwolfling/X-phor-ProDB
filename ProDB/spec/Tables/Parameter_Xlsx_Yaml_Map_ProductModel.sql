CREATE TABLE [spec].[Parameter_Xlsx_Yaml_Map_ProductModel] (
    [MapId]   INT          NOT NULL,
    [ProductModel]  VARCHAR(20)  NOT NULL,
    [Data_column]   VARCHAR(100) NOT NULL,
    [CreatedOn]     DATETIME     NOT NULL CONSTRAINT [DF_spec_PXYM_PM_CreatedOn] DEFAULT (GETDATE()),
    [CreatedBy]     NVARCHAR(50) NULL,
    CONSTRAINT [PK_spec_PXYM_ProductModel]
        PRIMARY KEY CLUSTERED ([MapId], [ProductModel]),
    CONSTRAINT [FK_spec_PXYM_ProductModel_ParameterMap]
        FOREIGN KEY ([MapId]) REFERENCES [spec].[Parameter_Xlsx_Yaml_Map]([ID]),
    CONSTRAINT [FK_spec_PXYM_ProductModel_ProductModel]
        FOREIGN KEY ([ProductModel]) REFERENCES [dbo].[ProductModel]([ProductModel])
);
GO

CREATE INDEX [IX_spec_PXYM_ProductModel_ProductModel]
    ON [spec].[Parameter_Xlsx_Yaml_Map_ProductModel]([ProductModel]);