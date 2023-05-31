CREATE TABLE [dbo].[CatServiceStatus] (
    [IdServiceStatus] INT            IDENTITY (1, 1) NOT NULL,
    [Name]            NVARCHAR (100) NULL,
    [Description]     VARCHAR (100)  NULL,
    [RowStatus]       BIT            NULL,
    [TokenCreated]    VARCHAR (50)   NOT NULL,
    [DateCreated]     DATETIME       NOT NULL,
    [TokenUpdated]    VARCHAR (50)   NULL,
    [DateUpdated]     DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([IdServiceStatus] ASC)
);




GO
CREATE NONCLUSTERED INDEX [NCI_CatServiceStatus_Name]
    ON [dbo].[CatServiceStatus]([Name] ASC);

