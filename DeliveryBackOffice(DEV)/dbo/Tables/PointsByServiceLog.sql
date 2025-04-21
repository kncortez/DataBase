CREATE TABLE [dbo].[PointsByServiceLog] (
    [IdPointsByServiceLog] BIGINT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [MembershipId]         INT             NOT NULL,
    [GuideSerie]           NVARCHAR (2)    NOT NULL,
    [GuideNumber]          INT             NOT NULL,
    [GuidePrice]           DECIMAL (18, 2) NOT NULL,
    [PointsReceived]       INT             DEFAULT ((0)) NULL,
    [PointsConsumed]       INT             DEFAULT ((0)) NULL,
    [RowStatus]            BIT             DEFAULT ((1)) NOT NULL,
    [DateCreated]          DATETIME        NOT NULL,
    [TokenCreated]         NVARCHAR (50)   NOT NULL,
    [DateUpdated]          DATETIME        NULL,
    [TokenUpdated]         NVARCHAR (50)   NULL,
    [TypeTransaction]      NVARCHAR (50)   NULL,
    [CatPointPromoId]      BIGINT          NULL,
    PRIMARY KEY CLUSTERED ([IdPointsByServiceLog] ASC),
    CONSTRAINT [CHK_PointsByService_Points] CHECK (isnull([PointsReceived],(0))>(0) AND isnull([PointsConsumed],(0))=(0) OR isnull([PointsReceived],(0))=(0) AND isnull([PointsConsumed],(0))>(0)),
    CONSTRAINT [FK_PointsByService_Guide] FOREIGN KEY ([GuideSerie], [GuideNumber]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number]),
    CONSTRAINT [FK_PointsByService_Membership] FOREIGN KEY ([MembershipId]) REFERENCES [dbo].[Membership] ([IdMembership]),
    CONSTRAINT [FK_PointsByServiceLog_CatPointPromo] FOREIGN KEY ([CatPointPromoId]) REFERENCES [dbo].[CatPointPromo] ([IdPointPromo])
);








GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la promoción de puntos adicionales aplicada', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PointsByServiceLog', @level2type = N'COLUMN', @level2name = N'CatPointPromoId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipo de transacción aplicada (MONTO o SERVICIO)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PointsByServiceLog', @level2type = N'COLUMN', @level2name = N'TypeTransaction';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PointsByServiceLog', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PointsByServiceLog', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PointsByServiceLog', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PointsByServiceLog', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PointsByServiceLog', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Puntos debitados por el servicio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PointsByServiceLog', @level2type = N'COLUMN', @level2name = N'PointsConsumed';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Puntos acreditados por el servicio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PointsByServiceLog', @level2type = N'COLUMN', @level2name = N'PointsReceived';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Precio de la guía (referencia para bitácora de puntos)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PointsByServiceLog', @level2type = N'COLUMN', @level2name = N'GuidePrice';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de la guía de la tabla DeliveryOrder', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PointsByServiceLog', @level2type = N'COLUMN', @level2name = N'GuideNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de la guía de la tabla DeliveryOrder', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PointsByServiceLog', @level2type = N'COLUMN', @level2name = N'GuideSerie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Membresía asociada a la acreditación o debito de puntos de la tabla Membership', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PointsByServiceLog', @level2type = N'COLUMN', @level2name = N'MembershipId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PointsByServiceLog', @level2type = N'COLUMN', @level2name = N'IdPointsByServiceLog';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Bitácora de acreditación o canjeo de puntos forza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PointsByServiceLog';


GO
CREATE NONCLUSTERED INDEX [idx_MembershipId_RowStatus]
    ON [dbo].[PointsByServiceLog]([MembershipId] ASC, [RowStatus] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_GuideSerie_GuideNumber_RowStatus]
    ON [dbo].[PointsByServiceLog]([GuideSerie] ASC, [GuideNumber] ASC, [RowStatus] ASC);

