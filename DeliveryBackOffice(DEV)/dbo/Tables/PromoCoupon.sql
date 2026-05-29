CREATE TABLE [dbo].[PromoCoupon] (
    [IdPromoCoupon]                        INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [CatPromoId]                           INT             NOT NULL,
    [PromoCouponSerie]                     NVARCHAR (20)   NOT NULL,
    [GuideSerieOrigin]                     NVARCHAR (2)    NULL,
    [GuideNumberOrigin]                    INT             NULL,
    [ServiceManagementOrigin]              INT             NULL,
    [SystemOrigin]                         INT             NOT NULL,
    [CustomerOrigin]                       INT             NULL,
    [VisitPointClientOrigin]               INT             NULL,
    [VisitPointClientPortfolioOrigin]      BIGINT          NULL,
    [GuideSerieDestination]                NVARCHAR (2)    NULL,
    [GuideNumberDestination]               INT             NULL,
    [ServiceManagementDestination]         INT             NULL,
    [SystemDestination]                    INT             NULL,
    [CustomerDestination]                  INT             NULL,
    [VisitPointClientDestination]          INT             NULL,
    [VisitPointClientPortfolioDestination] BIGINT          NULL,
    [CatDiscountTypeId]                    INT             NOT NULL,
    [CatValueTypeId]                       INT             NOT NULL,
    [CouponValue]                          DECIMAL (5, 2)  NOT NULL,
    [OriginalAmount]                       DECIMAL (18, 2) NULL,
    [DiscountAmount]                       DECIMAL (18, 2) NULL,
    [FinalAmount]                          DECIMAL (18, 2) NULL,
    [RedeemedDate]                         DATETIME        NULL,
    [StartActiveDate]                      DATETIME        NOT NULL,
    [FinalActiveDate]                      DATETIME        NOT NULL,
    [RowStatus]                            BIT             NOT NULL,
    [DateCreated]                          DATETIME        NOT NULL,
    [TokenCreated]                         NVARCHAR (50)   NOT NULL,
    [DateUpdated]                          DATETIME        NULL,
    [TokenUpdated]                         NVARCHAR (50)   NULL,
    PRIMARY KEY CLUSTERED ([IdPromoCoupon] ASC),
    CONSTRAINT [FK_PromoCoupon_CatPromo] FOREIGN KEY ([CatPromoId]) REFERENCES [dbo].[CatPromo] ([IdPromo]),
    CONSTRAINT [FK_PromoCoupon_CustomerDestination] FOREIGN KEY ([CustomerDestination]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [FK_PromoCoupon_CustomerOrigin] FOREIGN KEY ([CustomerOrigin]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [FK_PromoCoupon_DiscountType] FOREIGN KEY ([CatDiscountTypeId]) REFERENCES [dbo].[CatTypeDiscount] ([IdCatTypeDiscount]),
    CONSTRAINT [FK_PromoCoupon_GuideDestination] FOREIGN KEY ([GuideSerieDestination], [GuideNumberDestination]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number]),
    CONSTRAINT [FK_PromoCoupon_GuideOrigin] FOREIGN KEY ([GuideSerieOrigin], [GuideNumberOrigin]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number]),
    CONSTRAINT [FK_PromoCoupon_ServiceDestination] FOREIGN KEY ([ServiceManagementDestination]) REFERENCES [dbo].[ServiceManagement] ([IdServiceManagement]),
    CONSTRAINT [FK_PromoCoupon_ServiceOrigin] FOREIGN KEY ([ServiceManagementOrigin]) REFERENCES [dbo].[ServiceManagement] ([IdServiceManagement]),
    CONSTRAINT [FK_PromoCoupon_SystemDestination] FOREIGN KEY ([SystemDestination]) REFERENCES [dbo].[CatSystem] ([SysIdSystem]),
    CONSTRAINT [FK_PromoCoupon_SystemOrigin] FOREIGN KEY ([SystemOrigin]) REFERENCES [dbo].[CatSystem] ([SysIdSystem]),
    CONSTRAINT [FK_PromoCoupon_ValueType] FOREIGN KEY ([CatValueTypeId]) REFERENCES [dbo].[CatValueType] ([IdCatValueType]),
    CONSTRAINT [FK_PromoCoupon_VisitPointClientDestination] FOREIGN KEY ([VisitPointClientDestination]) REFERENCES [dbo].[VisitPointClient] ([CodeOfReference]),
    CONSTRAINT [FK_PromoCoupon_VisitPointClientOrigin] FOREIGN KEY ([VisitPointClientOrigin]) REFERENCES [dbo].[VisitPointClient] ([CodeOfReference]),
    CONSTRAINT [FK_PromoCoupon_VisitPointClientPortfolioDestination] FOREIGN KEY ([VisitPointClientPortfolioDestination]) REFERENCES [dbo].[VisitPointByClientPortfolio] ([IdVisitPointByClientPortfolio]),
    CONSTRAINT [FK_PromoCoupon_VisitPointClientPortfolioOrigin] FOREIGN KEY ([VisitPointClientPortfolioOrigin]) REFERENCES [dbo].[VisitPointByClientPortfolio] ([IdVisitPointByClientPortfolio])
);










GO



GO



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de cupones generados.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCoupon';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCoupon', @level2type = N'COLUMN', @level2name = N'IdPromoCoupon';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la promoción relacionada al cupon.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCoupon', @level2type = N'COLUMN', @level2name = N'CatPromoId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie del cupon, dato que identifica al cupon.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCoupon', @level2type = N'COLUMN', @level2name = N'PromoCouponSerie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de la guía que genero el cupon, si existiese.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCoupon', @level2type = N'COLUMN', @level2name = N'GuideSerieOrigin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Numero de la guía que genero el cupon, si existiese.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCoupon', @level2type = N'COLUMN', @level2name = N'GuideNumberOrigin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del servicio que genero el cupon, si existiese.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCoupon', @level2type = N'COLUMN', @level2name = N'ServiceManagementOrigin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del sistema donde se origino el cupon.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCoupon', @level2type = N'COLUMN', @level2name = N'SystemOrigin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del cliente que genero el cupon.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCoupon', @level2type = N'COLUMN', @level2name = N'CustomerOrigin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del punto de visita que genero el cupon.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCoupon', @level2type = N'COLUMN', @level2name = N'VisitPointClientOrigin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la cartera de clientes que genero el cupon', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCoupon', @level2type = N'COLUMN', @level2name = N'VisitPointClientPortfolioOrigin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de la guía donde se utilizo el cupon, si existiese.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCoupon', @level2type = N'COLUMN', @level2name = N'GuideSerieDestination';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Numero de la guía donde se utilizo el cupon, si existiese.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCoupon', @level2type = N'COLUMN', @level2name = N'GuideNumberDestination';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del servicio donde se utilizo el cupon, si existiese.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCoupon', @level2type = N'COLUMN', @level2name = N'ServiceManagementDestination';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del sistema donde se utilizo el cupon.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCoupon', @level2type = N'COLUMN', @level2name = N'SystemDestination';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del cliente que utilizo el cupon.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCoupon', @level2type = N'COLUMN', @level2name = N'CustomerDestination';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del punto de visita donde se utilizo el cupon.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCoupon', @level2type = N'COLUMN', @level2name = N'VisitPointClientDestination';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la cartera de clientes donde se utilizo el cupon.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCoupon', @level2type = N'COLUMN', @level2name = N'VisitPointClientPortfolioDestination';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del tipo de descuento que aplica el cupon.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCoupon', @level2type = N'COLUMN', @level2name = N'CatDiscountTypeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del tipo de valor para realizar el descuento.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCoupon', @level2type = N'COLUMN', @level2name = N'CatValueTypeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor del descuento a realizar.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCoupon', @level2type = N'COLUMN', @level2name = N'CouponValue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto original de la guía o servicio.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCoupon', @level2type = N'COLUMN', @level2name = N'OriginalAmount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto descontado del valor de la guía o servicio.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCoupon', @level2type = N'COLUMN', @level2name = N'DiscountAmount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor final tras aplicar el descuento de la guía o servicio.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCoupon', @level2type = N'COLUMN', @level2name = N'FinalAmount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha en la que se utilizo el cupon.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCoupon', @level2type = N'COLUMN', @level2name = N'RedeemedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha inicial para poder canjear el cupon.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCoupon', @level2type = N'COLUMN', @level2name = N'StartActiveDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha final para poder canjear el cupon.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCoupon', @level2type = N'COLUMN', @level2name = N'FinalActiveDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCoupon', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCoupon', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCoupon', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCoupon', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PromoCoupon', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
CREATE NONCLUSTERED INDEX [idx_PromoCouponSerie_RedeemedDate_RowStatus_FinalActiveDate]
    ON [dbo].[PromoCoupon]([PromoCouponSerie] ASC, [RedeemedDate] ASC, [RowStatus] ASC, [FinalActiveDate] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_GuideOrigin_Consolidated]
    ON [dbo].[PromoCoupon]([GuideSerieOrigin] ASC, [GuideNumberOrigin] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_GuideDestination_Consolidated]
    ON [dbo].[PromoCoupon]([GuideSerieDestination] ASC, [GuideNumberDestination] ASC);

