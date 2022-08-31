CREATE TABLE [dbo].[CatIncidenceClasification] (
    [IdCatIncidenceClasification] INT           IDENTITY (1, 1) NOT NULL,
    [IncidenceTypeName]           NVARCHAR (50) NOT NULL,
    [RowStatus]                   BIT           NOT NULL,
    [TokenCreated]                NVARCHAR (50) NOT NULL,
    [DateCreated]                 DATETIME      NOT NULL,
    [DateUpdated]                 DATETIME      NULL,
    [TokenUpdated]                NVARCHAR (50) NULL,
    PRIMARY KEY CLUSTERED ([IdCatIncidenceClasification] ASC)
);

