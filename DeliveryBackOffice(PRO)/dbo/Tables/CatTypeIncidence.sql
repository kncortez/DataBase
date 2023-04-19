CREATE TABLE [dbo].[CatTypeIncidence] (
    [IdIncidenceType]          INT           IDENTITY (1, 1) NOT NULL,
    [NameIncidence]            VARCHAR (200) NULL,
    [DescriptionIncidence]     VARCHAR (200) NULL,
    [RowStatus]                BIT           NOT NULL,
    [TokenCreated]             VARCHAR (50)  NOT NULL,
    [DateCreated]              DATETIME      NOT NULL,
    [TokenUpdated]             VARCHAR (50)  NULL,
    [DateUpdated]              DATETIME      NULL,
    [ServiceType]              NVARCHAR (25) NULL,
    [OrderId]                  INT           NULL,
    [Code]                     INT           NULL,
    [IncidenceClasificationId] INT           NULL,
    [IsForcedIncidence]        BIT           DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([IdIncidenceType] ASC)
);






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicativo si la incidencia esta forzada a ser incidencia en ruta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeIncidence', @level2type = N'COLUMN', @level2name = N'IsForcedIncidence';

