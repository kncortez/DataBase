CREATE TABLE [dbo].[IncidenceActionByTypeIncidence] (
    [IdIncidenceActionByTypeIncidence] INT          IDENTITY (1, 1) NOT NULL,
    [IncidenceTypeId]                  INT          NOT NULL,
    [IncidenceActionId]                INT          NOT NULL,
    [RowStatus]                        BIT          NOT NULL,
    [TokenCreated]                     VARCHAR (50) NOT NULL,
    [DateCreated]                      DATETIME     NOT NULL,
    [TokenUpdated]                     VARCHAR (50) NULL,
    [DateUpdated]                      DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([IdIncidenceActionByTypeIncidence] ASC),
    CONSTRAINT [IncidenceActionByCatTypeIncidence_FK] FOREIGN KEY ([IncidenceTypeId]) REFERENCES [dbo].[CatTypeIncidence] ([IdIncidenceType])
);

