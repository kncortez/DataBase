CREATE TABLE [dbo].[CatPromo] (
    [IdPromo]           INT            IDENTITY (1, 1) NOT NULL,
    [PromoDescription]  NVARCHAR (200) NOT NULL,
    [PromoWeight]       INT            NOT NULL,
    [StartPromoDate]    DATETIME       NOT NULL,
    [FinishPromoDate]   DATETIME       NOT NULL,
    [LimitPromoTime]    DECIMAL (6, 2) NULL,
    [Monday]            BIT            NOT NULL,
    [Tuesday]           BIT            NOT NULL,
    [Wednesday]         BIT            NOT NULL,
    [Thursday]          BIT            NOT NULL,
    [Friday]            BIT            NOT NULL,
    [Saturday]          BIT            NOT NULL,
    [Sunday]            BIT            NOT NULL,
    [CatValueTypeId]    INT            NOT NULL,
    [PromoValue]        DECIMAL (5, 2) NOT NULL,
    [CatDiscountTypeId] INT            NOT NULL,
    [RowStatus]         BIT            NOT NULL,
    [DateCreated]       DATETIME       NOT NULL,
    [TokenCreated]      NVARCHAR (50)  NOT NULL,
    [DateUpdated]       DATETIME       NULL,
    [TokenUpdated]      NVARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([IdPromo] ASC),
    CONSTRAINT [FK_CatPromo_CatDiscountType] FOREIGN KEY ([CatDiscountTypeId]) REFERENCES [dbo].[CatTypeDiscount] ([IdCatTypeDiscount]),
    CONSTRAINT [FK_CatPromo_CatValueType] FOREIGN KEY ([CatValueTypeId]) REFERENCES [dbo].[CatValueType] ([IdCatValueType])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catálogo de promociones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPromo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPromo', @level2type = N'COLUMN', @level2name = N'IdPromo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre de la promoción.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPromo', @level2type = N'COLUMN', @level2name = N'PromoDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor que determina la generación de un cupon en relación a otros (Mayor peso implica que se genera sobre los que tienen menor peso).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPromo', @level2type = N'COLUMN', @level2name = N'PromoWeight';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Referente a la generación de cupones, fecha de inicio de valides de la promoción.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPromo', @level2type = N'COLUMN', @level2name = N'StartPromoDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Referente a la generación de cupones, fecha final de valides de la promoción.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPromo', @level2type = N'COLUMN', @level2name = N'FinishPromoDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tiempo de valides de los cupones de la promoción (En horas).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPromo', @level2type = N'COLUMN', @level2name = N'LimitPromoTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Referente a la generación de cupones, indica si se pueden generar cupones los lunes.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPromo', @level2type = N'COLUMN', @level2name = N'Monday';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Referente a la generación de cupones, indica si se pueden generar cupones los martes.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPromo', @level2type = N'COLUMN', @level2name = N'Tuesday';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Referente a la generación de cupones, indica si se pueden generar cupones los miercoles.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPromo', @level2type = N'COLUMN', @level2name = N'Wednesday';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Referente a la generación de cupones, indica si se pueden generar cupones los jueves.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPromo', @level2type = N'COLUMN', @level2name = N'Thursday';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Referente a la generación de cupones, indica si se pueden generar cupones los viernes.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPromo', @level2type = N'COLUMN', @level2name = N'Friday';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Referente a la generación de cupones, indica si se pueden generar cupones los sabados.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPromo', @level2type = N'COLUMN', @level2name = N'Saturday';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Referente a la generación de cupones, indica si se pueden generar cupones los domingos.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPromo', @level2type = N'COLUMN', @level2name = N'Sunday';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del tipo de valor a descontar en la promoción (Ej: %, Q, etc.).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPromo', @level2type = N'COLUMN', @level2name = N'CatValueTypeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor a descontar de la promoción.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPromo', @level2type = N'COLUMN', @level2name = N'PromoValue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del tipo de descuento a realizar (Ej: Base, Total, etc.),', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPromo', @level2type = N'COLUMN', @level2name = N'CatDiscountTypeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPromo', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPromo', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPromo', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPromo', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualziación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPromo', @level2type = N'COLUMN', @level2name = N'TokenUpdated';

