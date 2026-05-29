CREATE TABLE [dbo].[CatSeries] (
    [IdSerie]          VARCHAR (10) NULL,
    [SerieStatus]      INT          NULL,
    [SerieDateCreated] DATETIME     NULL,
    [SerieTokenCreate] VARCHAR (50) NULL,
    [SerieDateUpdate]  DATETIME     NULL,
    [SerieTokenUpdate] NCHAR (10)   NULL,
    [IdCatSerie]       INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    CONSTRAINT [PK_CatSeries] PRIMARY KEY CLUSTERED ([IdCatSerie] ASC)
);

