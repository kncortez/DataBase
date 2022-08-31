CREATE TABLE [dbo].[CatIncidenceAction] (
    [IdCatIncidenceAction] INT          IDENTITY (1, 1) NOT NULL,
    [IncidenceActionName]  VARCHAR (50) NOT NULL,
    [RowStatus]            BIT          NOT NULL,
    [TokenCreated]         VARCHAR (50) NOT NULL,
    [DateCreated]          DATETIME     NOT NULL,
    [TokenUpdated]         VARCHAR (50) NULL,
    [DateUpdated]          DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([IdCatIncidenceAction] ASC)
);

