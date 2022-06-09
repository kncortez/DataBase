CREATE TABLE [dbo].[TypeServiceManagment] (
    [IdTypeServiceManagment] BIGINT         IDENTITY (1, 1) NOT NULL,
    [Name]                   NVARCHAR (200) NOT NULL,
    [RowStatus]              BIT            NOT NULL,
    [TokenCreated]           VARCHAR (150)  NOT NULL,
    [DateCreated]            DATETIME       NOT NULL,
    [TokenUpdated]           VARCHAR (150)  NULL,
    [DateUpdated]            DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([IdTypeServiceManagment] ASC)
);

