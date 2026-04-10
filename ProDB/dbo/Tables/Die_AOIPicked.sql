CREATE TABLE [dbo].[Die_AOIPicked] (
    [DieID]                INT            NOT NULL,
    [Cdt]                  DATETIME       DEFAULT (getdate()) NULL,
    [jpgPath]              VARCHAR (1000) NULL,
    [jpgModifieddatetime]  DATETIME       NULL,
    [GjpgPath]             VARCHAR (1000) NULL,
    [GjpgModifieddatetime] DATETIME       NULL,
    [Udt]                  DATETIME       CONSTRAINT [DF_Die_AOIPicked_Udt] DEFAULT (getdate()) NULL,
    [DefectAreaCode]       VARCHAR (2)    NULL,
    [DefectTypeCode]       VARCHAR (2)    NULL,
    [DefectCode]           VARCHAR (5)    NULL,
    CONSTRAINT [PK_Die_AOIPicked] PRIMARY KEY CLUSTERED ([DieID] ASC)
);






GO
GRANT UPDATE
    ON OBJECT::[dbo].[Die_AOIPicked] TO [Production]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[Die_AOIPicked] TO [Production]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[Die_AOIPicked] TO [Production]
    AS [dbo];

