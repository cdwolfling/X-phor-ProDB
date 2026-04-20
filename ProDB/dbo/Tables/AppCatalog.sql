CREATE TABLE [dbo].[AppCatalog] (
    [AppID]       INT            IDENTITY (1, 1) NOT NULL,
    [AppName]     NVARCHAR (128) NOT NULL,
    [Version]     VARCHAR (50)   NOT NULL,
    [ReleaseDate] DATETIME2 (7)  DEFAULT (sysutcdatetime()) NOT NULL,
    [IsEnabled]   BIT            DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_AppCatalog] PRIMARY KEY CLUSTERED ([AppID] ASC),
    CONSTRAINT [UQ_AppCatalog_NameVer] UNIQUE NONCLUSTERED ([AppName] ASC, [Version] ASC)
);




GO
GRANT SELECT
    ON OBJECT::[dbo].[AppCatalog] TO [Production]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[AppCatalog] TO [SpecMaintainer]
    AS [dbo];

