CREATE TABLE [spec].[ProductFamilySpec] (
    [ProductFamilySpecId] INT             IDENTITY (1, 1) NOT NULL,
    [ProductFamily]       VARCHAR (50)    NOT NULL,
    [SpecVersion]         INT             NOT NULL,
    [IsActive]            BIT             CONSTRAINT [DF_spec_ProductFamilySpec_IsActive] DEFAULT ((1)) NOT NULL,
    [EffectiveDate]       DATE            NULL,
    [Remark]              NVARCHAR (1000) NULL,
    [CreatedOn]           DATETIME        CONSTRAINT [DF_spec_ProductFamilySpec_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]           NVARCHAR (50)   NULL,
    CONSTRAINT [PK_spec_ProductFamilySpec] PRIMARY KEY CLUSTERED ([ProductFamilySpecId] ASC),
    CONSTRAINT [UQ_spec_ProductFamilySpec_ProductFamily_SpecVersion] UNIQUE NONCLUSTERED ([ProductFamily] ASC, [SpecVersion] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_spec_ProductFamilySpec_ProductFamily_Active]
    ON [spec].[ProductFamilySpec]([ProductFamily] ASC) WHERE ([IsActive]=(1));


GO
GRANT UPDATE
    ON OBJECT::[spec].[ProductFamilySpec] TO [Production]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[spec].[ProductFamilySpec] TO [Production]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[spec].[ProductFamilySpec] TO [Production]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[spec].[ProductFamilySpec] TO [Production]
    AS [dbo];


GO
GRANT ALTER
    ON OBJECT::[spec].[ProductFamilySpec] TO [Production]
    AS [dbo];

