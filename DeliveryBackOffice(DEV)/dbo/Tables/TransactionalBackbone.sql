CREATE TABLE [dbo].[TransactionalBackbone] (
    [IdTransactionalMovement] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [GuideSerie]              NVARCHAR (2)  NOT NULL,
    [GuideNumber]             INT           NOT NULL,
    [GuidePiece]              INT           NOT NULL,
    [RouteId]                 INT           NOT NULL,
    [InBound]                 INT           NOT NULL,
    [OutBound]                INT           NOT NULL,
    [LineHaul]                BIT           NULL,
    [StatusComplete]          BIT           NULL,
    [TransactionTypeId]       INT           NOT NULL,
    [CountryId]               VARCHAR (2)   NOT NULL,
    [HubId]                   INT           NULL,
    [TypeOfPieceId]           INT           NULL,
    [ServiceManagmentID]      INT           NULL,
    [RowStatus]               BIT           NOT NULL,
    [TokenCreated]            NVARCHAR (50) NOT NULL,
    [DateCreated]             DATETIME      NOT NULL,
    [TokenUpdated]            NVARCHAR (50) NULL,
    [DateUpdated]             DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdTransactionalMovement] ASC),
    FOREIGN KEY ([CountryId]) REFERENCES [dbo].[CatCountry] ([IdCountry]),
    FOREIGN KEY ([HubId]) REFERENCES [dbo].[HubLogistics] ([IdHubLogistic]),
    FOREIGN KEY ([InBound]) REFERENCES [dbo].[CatTransportationZone] ([IdTranportationZone]),
    FOREIGN KEY ([OutBound]) REFERENCES [dbo].[CatTransportationZone] ([IdTranportationZone]),
    FOREIGN KEY ([RouteId]) REFERENCES [dbo].[CatRoute] ([IdRoute]),
    FOREIGN KEY ([ServiceManagmentID]) REFERENCES [dbo].[ServiceManagement] ([IdServiceManagement]),
    FOREIGN KEY ([TransactionTypeId]) REFERENCES [dbo].[TransactionType] ([IdTransactionType])
);








GO



GO



GO
CREATE NONCLUSTERED INDEX [idx_DateCreated_RowStatus]
    ON [dbo].[TransactionalBackbone]([DateCreated] ASC, [RowStatus] ASC);

