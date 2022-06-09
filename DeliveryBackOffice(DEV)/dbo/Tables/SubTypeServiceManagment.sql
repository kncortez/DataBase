CREATE TABLE [dbo].[SubTypeServiceManagment] (
    [IdSubTypeServiceManagment] BIGINT         IDENTITY (1, 1) NOT NULL,
    [TypeServiceManagmentId]    BIGINT         NOT NULL,
    [Name]                      NVARCHAR (200) NULL,
    [RowStatus]                 BIT            NOT NULL,
    [TokenCreated]              VARCHAR (150)  NOT NULL,
    [DateCreated]               DATETIME       NOT NULL,
    [TokenUpdated]              VARCHAR (150)  NULL,
    [DateUpdated]               DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([IdSubTypeServiceManagment] ASC),
    CONSTRAINT [FK_SubTypeServiceManagment_TypeServiceManagmentId] FOREIGN KEY ([TypeServiceManagmentId]) REFERENCES [dbo].[TypeServiceManagment] ([IdTypeServiceManagment])
);

