CREATE TABLE [dbo].[PromoCouponProcessLog] (
    [IdPromoCouponProcessLog]     BIGINT          IDENTITY (1, 1) NOT NULL,
    [AccountServiceCartId]        INT             NULL,
    [ExpressAccountServiceCartId] BIGINT          NULL,
    [ProcessAttempt]              BIGINT          DEFAULT ((1)) NOT NULL,
    [CatPromoId]                  INT             NULL,
    [GuideSerieOrigin]            NVARCHAR (2)    NOT NULL,
    [GuideNumberOrigin]           INT             NOT NULL,
    [GuideSerieDestiny]           NVARCHAR (2)    NULL,
    [GuideNumberDestiny]          INT             NULL,
    [OriginGuideAmount]           DECIMAL (18, 2) NOT NULL,
    [DestinyGuideAmount]          DECIMAL (18, 2) NULL,
    [RowStatus]                   BIT             DEFAULT ((1)) NOT NULL,
    [DateCreated]                 DATETIME        NOT NULL,
    [TokenCreated]                NVARCHAR (50)   NOT NULL,
    [DateUpdated]                 DATETIME        NULL,
    [TokenUpdated]                NVARCHAR (50)   NULL,
    PRIMARY KEY CLUSTERED ([IdPromoCouponProcessLog] ASC),
    CONSTRAINT [CHCK_ServiceCart] CHECK ([AccountServiceCartId] IS NULL AND [ExpressAccountServiceCartId] IS NOT NULL OR [AccountServiceCartId] IS NOT NULL AND [ExpressAccountServiceCartId] IS NULL),
    CONSTRAINT [FK_PromoCouponProcess_ExpressServiceCart] FOREIGN KEY ([ExpressAccountServiceCartId]) REFERENCES [dbo].[ExpressAccountServiceCart] ([IdExpressAccountServiceCart]),
    CONSTRAINT [FK_PromoCouponProcess_GuideDestiny] FOREIGN KEY ([GuideSerieDestiny], [GuideNumberDestiny]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number]),
    CONSTRAINT [FK_PromoCouponProcess_GuideOrigin] FOREIGN KEY ([GuideSerieOrigin], [GuideNumberOrigin]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number]),
    CONSTRAINT [FK_PromoCouponProcess_Promo] FOREIGN KEY ([CatPromoId]) REFERENCES [dbo].[CatPromo] ([IdPromo]),
    CONSTRAINT [FK_PromoCouponProcess_ServiceCart] FOREIGN KEY ([AccountServiceCartId]) REFERENCES [dbo].[AccountServiceCart] ([IdAccountServiceCart])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCouponProcessLog', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCouponProcessLog', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCouponProcessLog', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCouponProcessLog', @level2type = N'COLUMN', @level2name = N'DateCreated';




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCouponProcessLog', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto envío de la guía de destino.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCouponProcessLog', @level2type = N'COLUMN', @level2name = N'DestinyGuideAmount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto envío de la guía de origen.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCouponProcessLog', @level2type = N'COLUMN', @level2name = N'OriginGuideAmount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de guía de destino del proceso de la tabla DeliveryOrder.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCouponProcessLog', @level2type = N'COLUMN', @level2name = N'GuideNumberDestiny';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de guía de destino del proceso de la tabla DeliveryOrder.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCouponProcessLog', @level2type = N'COLUMN', @level2name = N'GuideSerieDestiny';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de guía de origen del proceso de la tabla DeliveryOrder.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCouponProcessLog', @level2type = N'COLUMN', @level2name = N'GuideNumberOrigin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de guía de origen del proceso de la tabla DeliveryOrder.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCouponProcessLog', @level2type = N'COLUMN', @level2name = N'GuideSerieOrigin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la promoción de cupon a aplicar de la tabla CatPromo.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCouponProcessLog', @level2type = N'COLUMN', @level2name = N'CatPromoId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de intento de procesamiento.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCouponProcessLog', @level2type = N'COLUMN', @level2name = N'ProcessAttempt';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del carrito de compras de usuario redistribuidor de la tabla ExpressAccountServiceCart.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCouponProcessLog', @level2type = N'COLUMN', @level2name = N'ExpressAccountServiceCartId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del carrito de compras de usuario individual de la tabla AccountServiceCart.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCouponProcessLog', @level2type = N'COLUMN', @level2name = N'AccountServiceCartId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCouponProcessLog', @level2type = N'COLUMN', @level2name = N'IdPromoCouponProcessLog';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de bitácora de procesos de generación de cupones a partir de carrito de compras de usuario.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCouponProcessLog';

