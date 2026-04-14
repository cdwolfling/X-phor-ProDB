CREATE TABLE [fab].[tFAB_LT] (
    [ID]       INT          NULL,
    [FabName]  VARCHAR (10) NULL,
    [Layer]    INT          NULL,
    [LeadTime] INT          NULL
);


GO
GRANT UPDATE
    ON OBJECT::[fab].[tFAB_LT] TO [Production]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[fab].[tFAB_LT] TO [Production]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[fab].[tFAB_LT] TO [Production]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[fab].[tFAB_LT] TO [Production]
    AS [dbo];


GO
GRANT ALTER
    ON OBJECT::[fab].[tFAB_LT] TO [Production]
    AS [dbo];

