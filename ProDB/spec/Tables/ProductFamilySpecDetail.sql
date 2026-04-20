CREATE TABLE [spec].[ProductFamilySpecDetail] (
    [ProductFamilySpecDetailId] INT             IDENTITY (1, 1) NOT NULL,
    [ProductFamilySpecId]       INT             NOT NULL,
    [ParameterId]               INT             NOT NULL,
    [SpecValue]                 DECIMAL (18, 6) NOT NULL,
    CONSTRAINT [PK_spec_ProductFamilySpecDetail] PRIMARY KEY CLUSTERED ([ProductFamilySpecDetailId] ASC),
    CONSTRAINT [FK_spec_ProductFamilySpecDetail_ParameterDef] FOREIGN KEY ([ParameterId]) REFERENCES [spec].[ParameterDef] ([ParameterId]),
    CONSTRAINT [FK_spec_ProductFamilySpecDetail_ProductFamilySpec] FOREIGN KEY ([ProductFamilySpecId]) REFERENCES [spec].[ProductFamilySpec] ([ProductFamilySpecId]),
    CONSTRAINT [UQ_spec_ProductFamilySpecDetail_ProductFamilySpecId_ParameterId] UNIQUE NONCLUSTERED ([ProductFamilySpecId] ASC, [ParameterId] ASC)
);




GO
CREATE NONCLUSTERED INDEX [IX_spec_ProductFamilySpecDetail_ParameterId]
    ON [spec].[ProductFamilySpecDetail]([ParameterId] ASC);


GO



GO



GO



GO



GO
GRANT UPDATE
    ON OBJECT::[spec].[ProductFamilySpecDetail] TO [SpecMaintainer]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[spec].[ProductFamilySpecDetail] TO [SpecMaintainer]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[spec].[ProductFamilySpecDetail] TO [SpecMaintainer]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[spec].[ProductFamilySpecDetail] TO [SpecMaintainer]
    AS [dbo];


GO
GRANT ALTER
    ON OBJECT::[spec].[ProductFamilySpecDetail] TO [SpecMaintainer]
    AS [dbo];

