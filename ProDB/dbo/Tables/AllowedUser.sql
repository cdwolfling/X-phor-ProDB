CREATE TABLE [dbo].[AllowedUser] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [DomainAccount] NVARCHAR (100) NOT NULL,
    [DisplayName]   NVARCHAR (100) NULL,
    [Role]          NVARCHAR (20)  DEFAULT ('User') NOT NULL,
    [CreatedOn]     DATETIME2 (7)  NOT NULL,
    [CreatedBy]     NVARCHAR (50)  NULL,
    CONSTRAINT [PK_AllowedUser] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_AllowedUser_DomainAccount]
    ON [dbo].[AllowedUser]([DomainAccount] ASC);

