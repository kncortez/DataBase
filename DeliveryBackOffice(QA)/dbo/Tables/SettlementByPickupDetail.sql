CREATE TABLE [dbo].[SettlementByPickupDetail] (
    [IdSettlementByPickupDetail] INT             IDENTITY (1, 1) NOT NULL,
    [SettlementByPickupId]       INT             NULL,
    [GuideSerie]                 NVARCHAR (2)    NOT NULL,
    [GuideNumber]                INT             NOT NULL,
    [RowStatus]                  BIT             NULL,
    [TokenCreated]               NVARCHAR (150)  NOT NULL,
    [DateCreated]                DATETIME        NOT NULL,
    [TokenUpdated]               NVARCHAR (150)  NULL,
    [DateUpdated]                DATETIME        NULL,
    [IsPieceLiquidaded]          BIT             NULL,
    [NoPiece]                    INT             NULL,
    [IsDispatched]               BIT             NULL,
    [IsReturn]                   BIT             NULL,
    [IsCODSettlement]            INT             NULL,
    [CODSettlement_TokenCreated] NVARCHAR (50)   NULL,
    [CODSettlement_DateCreated]  DATETIME        NULL,
    [Price]                      DECIMAL (14, 2) NULL,
    PRIMARY KEY CLUSTERED ([IdSettlementByPickupDetail] ASC),
    CONSTRAINT [FKSettlementByPickupId] FOREIGN KEY ([SettlementByPickupId]) REFERENCES [dbo].[SettlementByPickup] ([Id])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para poder registrar si la guía fué liquidada en recolección COD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SettlementByPickupDetail', @level2type = N'COLUMN', @level2name = N'IsCODSettlement';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para poder registrar el token de liquidación recolección COD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SettlementByPickupDetail', @level2type = N'COLUMN', @level2name = N'CODSettlement_TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para poder registrar la fecha y hora de liquidación recolección COD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SettlementByPickupDetail', @level2type = N'COLUMN', @level2name = N'CODSettlement_DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Precio de envío a pagar.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SettlementByPickupDetail', @level2type = N'COLUMN', @level2name = N'Price';


GO
CREATE NONCLUSTERED INDEX [idx_SettlementByPickupId]
    ON [dbo].[SettlementByPickupDetail]([SettlementByPickupId] ASC)
    INCLUDE([GuideSerie], [GuideNumber]);

