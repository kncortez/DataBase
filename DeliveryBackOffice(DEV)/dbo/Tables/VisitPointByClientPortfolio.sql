CREATE TABLE [dbo].[VisitPointByClientPortfolio] (
    [IdVisitPointByClientPortfolio] BIGINT         IDENTITY (1, 1) NOT NULL,
    [FirstName]                     VARCHAR (100)  NULL,
    [SecondName]                    NVARCHAR (50)  NULL,
    [LastName]                      NVARCHAR (50)  NULL,
    [SecondLastName]                NVARCHAR (50)  NULL,
    [Email]                         NVARCHAR (200) NULL,
    [NirPhone]                      NVARCHAR (10)  NULL,
    [Phone]                         NVARCHAR (20)  NULL,
    [CUI]                           NVARCHAR (100) NULL,
    [VisitPointId]                  INT            NULL,
    [RowStatus]                     BIT            NOT NULL,
    [TokenCreated]                  NVARCHAR (150) NOT NULL,
    [DateCreated]                   DATETIME       NOT NULL,
    [TokenUpdated]                  NVARCHAR (150) NULL,
    [DateUpdated]                   DATETIME       NULL,
    [InternalCode]                  VARCHAR (50)   NULL,
    [TaxId]                         VARCHAR (50)   NULL,
    [ContactName]                   VARCHAR (50)   NULL,
    CONSTRAINT [PK_VisitPointByClientPortfolio] PRIMARY KEY CLUSTERED ([IdVisitPointByClientPortfolio] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_VisitPointByClientPortfolio_LoadList]
    ON [dbo].[VisitPointByClientPortfolio]([VisitPointId] ASC, [RowStatus] ASC);

