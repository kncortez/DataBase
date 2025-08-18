CREATE TABLE [dbo].[CatTypeCharge] (
    [IdTypeCharge] INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Name]         NVARCHAR (200) NULL,
    [RowStatus]    BIT            NULL,
    [TokenCreated] VARCHAR (50)   NOT NULL,
    [DateCreated]  DATETIME       NOT NULL,
    [TokenUpdated] VARCHAR (50)   NULL,
    [DateUpdated]  DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([IdTypeCharge] ASC)
);

