CREATE TABLE [dbo].[AllowedUser] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [Module]        NVARCHAR (100) NOT NULL,
    [DomainAccount] NVARCHAR (100) NOT NULL,
    [DisplayName]   NVARCHAR (100) NULL,
    [Role]          NVARCHAR (20)  CONSTRAINT [DF__AllowedUse__Role] DEFAULT ('User') NOT NULL,
    [CreatedOn]     DATETIME       CONSTRAINT [DF_AllowedUser_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]     NVARCHAR (50)  NULL,
    CONSTRAINT [PK_AllowedUser] PRIMARY KEY CLUSTERED ([Id] ASC)
);






GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_AllowedUser_Module_DomainAccount]
    ON [dbo].[AllowedUser]([Module] ASC, [DomainAccount] ASC);

