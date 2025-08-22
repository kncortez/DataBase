CREATE TABLE [dbo].[PromoCoverage] (
    [IdPromoCoverage]    INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [CatPromoId]         INT           NOT NULL,
    [CustomerId]         INT           NULL,
    [VisitPointClientId] INT           NULL,
    [CustomerTypeId]     INT           NULL,
    [RowStatus]          BIT           NOT NULL,
    [DateCreated]        DATETIME      NOT NULL,
    [TokenCreated]       NVARCHAR (50) NOT NULL,
    [DateUpdated]        DATETIME      NULL,
    [TokenUpdated]       NVARCHAR (50) NULL,
    PRIMARY KEY CLUSTERED ([IdPromoCoverage] ASC),
    CONSTRAINT [CHK_PromoCoverage_Minimum] CHECK (isnull([CustomerId],(0))>(0) OR isnull([VisitPointClientId],(0))>(0) OR isnull([CustomerTypeId],(0))>(0)),
    CONSTRAINT [FK_PromoCoverage_CatPromo] FOREIGN KEY ([CatPromoId]) REFERENCES [dbo].[CatPromo] ([IdPromo]),
    CONSTRAINT [FK_PromoCoverage_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [FK_PromoCoverage_CustomerType] FOREIGN KEY ([CustomerTypeId]) REFERENCES [dbo].[CustomerType] ([IdCustomerType]),
    CONSTRAINT [FK_PromoCoverage_VisitPointClient] FOREIGN KEY ([VisitPointClientId]) REFERENCES [dbo].[VisitPointClient] ([CodeOfReference])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cobertura de promociones basada en cleinte, punto de visita o tipo de cliente.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCoverage';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCoverage', @level2type = N'COLUMN', @level2name = N'IdPromoCoverage';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la promoción.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCoverage', @level2type = N'COLUMN', @level2name = N'CatPromoId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Referente a la creación de cupones, identificador de cliente a quien aplica la promoción.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCoverage', @level2type = N'COLUMN', @level2name = N'CustomerId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Referente a la creación de cupones, identificador de punto de visita al cual aplica la promoción.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCoverage', @level2type = N'COLUMN', @level2name = N'VisitPointClientId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Referente a la creación de cupones, identificador de tipo de cliente a quienes aplica la promoción.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCoverage', @level2type = N'COLUMN', @level2name = N'CustomerTypeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCoverage', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCoverage', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCoverage', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCoverage', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCoverage', @level2type = N'COLUMN', @level2name = N'TokenUpdated';

