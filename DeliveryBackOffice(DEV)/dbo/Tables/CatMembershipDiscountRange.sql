CREATE TABLE [dbo].[CatMembershipDiscountRange] (
    [IdCatMembershipDiscountRange] INT            IDENTITY (1, 1) NOT NULL,
    [CatMembershipId]              INT            NOT NULL,
    [DiscountLowServiceRange]      INT            NOT NULL,
    [DiscountTopServiceRange]      INT            NULL,
    [ValueTypeId]                  INT            NOT NULL,
    [DiscountValue]                DECIMAL (5, 2) NOT NULL,
    [RowStatus]                    BIT            CONSTRAINT [DF_CatMembershipDiscountRange_RowStatus] DEFAULT ((1)) NOT NULL,
    [TokenCreated]                 NVARCHAR (50)  NOT NULL,
    [DateCreated]                  DATETIME       NOT NULL,
    [TokenUpdated]                 NVARCHAR (50)  NULL,
    [DateUpdated]                  DATETIME       NULL,
    CONSTRAINT [PK_CatMembershipDiscountRange] PRIMARY KEY CLUSTERED ([IdCatMembershipDiscountRange] ASC),
    CONSTRAINT [FK_CatMembershipDiscountRange_CatMembership] FOREIGN KEY ([CatMembershipId]) REFERENCES [dbo].[CatMembership] ([IdCatMembership]),
    CONSTRAINT [FK_CatMembershipDiscountRange_CatValueType] FOREIGN KEY ([ValueTypeId]) REFERENCES [dbo].[CatValueType] ([IdCatValueType])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'llave foranea para tabla de tipo de valor', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatMembershipDiscountRange', @level2type = N'COLUMN', @level2name = N'ValueTypeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualización de registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatMembershipDiscountRange', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'token de creacion del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatMembershipDiscountRange', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'estado del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatMembershipDiscountRange', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificación del catalogo de rango de descuento de membresías', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatMembershipDiscountRange', @level2type = N'COLUMN', @level2name = N'IdCatMembershipDiscountRange';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'valor del descuento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatMembershipDiscountRange', @level2type = N'COLUMN', @level2name = N'DiscountValue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descuento del servicio mas alto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatMembershipDiscountRange', @level2type = N'COLUMN', @level2name = N'DiscountTopServiceRange';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descuento del servicio mas bajo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatMembershipDiscountRange', @level2type = N'COLUMN', @level2name = N'DiscountLowServiceRange';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fecha de actualización de registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatMembershipDiscountRange', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatMembershipDiscountRange', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave foranea para relación de tabla catalogo de membresías', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatMembershipDiscountRange', @level2type = N'COLUMN', @level2name = N'CatMembershipId';

