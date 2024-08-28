CREATE TABLE [dbo].[DeliveryBank] (
    [Id_bank]     INT            NOT NULL,
    [Name]        NVARCHAR (50)  NOT NULL,
    [Acronym]     NVARCHAR (15)  NULL,
    [Description] NVARCHAR (255) NULL,
    [create_date] DATETIME       NOT NULL,
    [Id_status]   INT            NOT NULL,
    [Id_country]  NVARCHAR (2)   NOT NULL,
    [URL_logo]    TEXT           NULL,
    [CardCode]    NVARCHAR (50)  NULL,
    [ACHCode]     INT            NULL,
    [PayingBank]  INT            CONSTRAINT [DF_DeliveryBank_PayingBank] DEFAULT ((31)) NULL,
    CONSTRAINT [PK_SP_DEPOSITOS_BANCOS] PRIMARY KEY CLUSTERED ([Id_bank] ASC),
    CONSTRAINT [FK_DeliveryBank_IdBank_PayingBank] FOREIGN KEY ([PayingBank]) REFERENCES [dbo].[DeliveryBank] ([Id_bank])
);




GO
CREATE NONCLUSTERED INDEX [IX_DeliveryBankRDL]
    ON [dbo].[DeliveryBank]([Id_bank] ASC, [Id_country] ASC, [Id_status] ASC);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'identificador de registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryBank',
    @level2type = N'COLUMN',
    @level2name = N'Id_bank'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Nombre de banco',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryBank',
    @level2type = N'COLUMN',
    @level2name = N'Name'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Acronimo del banco',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryBank',
    @level2type = N'COLUMN',
    @level2name = N'Acronym'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Descripción del banco',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryBank',
    @level2type = N'COLUMN',
    @level2name = N'Description'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de creación ',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryBank',
    @level2type = N'COLUMN',
    @level2name = N'create_date'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado(1 Activo, 0 Inactivo)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryBank',
    @level2type = N'COLUMN',
    @level2name = N'Id_status'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'id de pais(GT, HN, PA)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryBank',
    @level2type = N'COLUMN',
    @level2name = N'Id_country'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ruta del logo',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryBank',
    @level2type = N'COLUMN',
    @level2name = N'URL_logo'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de tarjeta',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryBank',
    @level2type = N'COLUMN',
    @level2name = N'CardCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código ACH',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryBank',
    @level2type = N'COLUMN',
    @level2name = N'ACHCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'id del banco superior(Referencia a id_bank de la tabla DeliveryBank)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryBank',
    @level2type = N'COLUMN',
    @level2name = N'PayingBank'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Catálogo de bancos',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryBank',
    @level2type = NULL,
    @level2name = NULL