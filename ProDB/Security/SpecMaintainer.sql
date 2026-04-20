CREATE ROLE [SpecMaintainer]
    AUTHORIZATION [dbo];


GO
ALTER ROLE [SpecMaintainer] ADD MEMBER [Production];

