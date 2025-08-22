CREATE TABLE [dbo].[CatBreakdownOfPaymentType] (
    [IdCatBreakdownOfPaymentType]       INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [BreakdownOfPaymentTypeName]        NVARCHAR (200) NOT NULL,
    [BreakdownOfPaymentTypeDescription] NVARCHAR (600) NULL,
    [RowStatus]                         BIT            DEFAULT ((1)) NOT NULL,
    [DateCreated]                       DATETIME       NOT NULL,
    [TokenCreated]                      NVARCHAR (50)  NOT NULL,
    [DateUpdated]                       DATETIME       NULL,
    [TokenUpdated]                      NVARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([IdCatBreakdownOfPaymentType] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatBreakdownOfPaymentType', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatBreakdownOfPaymentType', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatBreakdownOfPaymentType', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatBreakdownOfPaymentType', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatBreakdownOfPaymentType', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del detalle de cobro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatBreakdownOfPaymentType', @level2type = N'COLUMN', @level2name = N'BreakdownOfPaymentTypeDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del detalle de cobro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatBreakdownOfPaymentType', @level2type = N'COLUMN', @level2name = N'BreakdownOfPaymentTypeName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatBreakdownOfPaymentType', @level2type = N'COLUMN', @level2name = N'IdCatBreakdownOfPaymentType';

