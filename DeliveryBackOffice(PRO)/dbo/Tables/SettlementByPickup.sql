CREATE TABLE [dbo].[SettlementByPickup] (
    [Id]                        INT           IDENTITY (1, 1) NOT NULL,
    [RouteAssigmentId]          INT           NULL,
    [DatePrinted]               DATETIME      NULL,
    [TokenCreated]              VARCHAR (50)  NOT NULL,
    [DateCreated]               DATETIME      NOT NULL,
    [PiecesDry]                 SMALLINT      NULL,
    [PiecesCold]                SMALLINT      NULL,
    [GuidesQuantity]            SMALLINT      NULL,
    [PiecesDryReceived]         SMALLINT      NULL,
    [PiecesColdReceived]        SMALLINT      NULL,
    [GuidesQuantityReceived]    SMALLINT      NULL,
    [IdCourier]                 INT           NULL,
    [ServiceManagmentId]        INT           NULL,
    [SequenceCode]              BIGINT        NULL,
    [SubTypeServiceManagmentId] INT           NULL,
    [StartingKilometers]        NVARCHAR (50) NULL,
    [ArrivalKilometers]         NVARCHAR (50) NULL,
    [TokenUpdated]              NVARCHAR (50) NULL,
    [DateUpdated]               DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);




GO
CREATE NONCLUSTERED INDEX [idx_SequenceCode]
    ON [dbo].[SettlementByPickup]([SequenceCode] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_IdCourier_DateCreated]
    ON [dbo].[SettlementByPickup]([IdCourier] ASC, [DateCreated] ASC)
    INCLUDE([Id]);

