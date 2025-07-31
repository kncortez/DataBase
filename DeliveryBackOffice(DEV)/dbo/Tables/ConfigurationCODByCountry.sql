USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[ConfigurationCODByCountry]    Script Date: 23/04/2025 11:31:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ConfigurationCODByCountry](
	[IdConfigurationCODByCountry] [int] IDENTITY(1,1) NOT NULL,
	[CountryId] [nvarchar](4) NOT NULL,
	[DCBAId] [int] NOT NULL,
	[BankId] [int] NOT NULL,
	[CatBankAccountTypeId] [int] NOT NULL,
	[InAccount] [nvarchar](50) NULL,
	[OutAccount] [nvarchar](50) NULL,
	[ConceptCustomer] [nvarchar](50) NULL,
	[ConceptForza] [nvarchar](50) NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
	PRIMARY KEY CLUSTERED ([IdConfigurationCODByCountry] ASC),
	CONSTRAINT [FK_ConfigurationCODByCountry_CatBankAccountType] FOREIGN KEY([CatBankAccountTypeId]) REFERENCES [dbo].[CatBankAccountType] ([IdBankAccountType]),
	CONSTRAINT [FK_ConfigurationCODByCountry_DeliveryBank] FOREIGN KEY([BankId]) REFERENCES [dbo].[DeliveryBank] ([Id_bank]),
	CONSTRAINT [FK_ConfigurationCODByCountry_DeliveryCustomerBankAccount] FOREIGN KEY([DCBAId]) REFERENCES [dbo].[DeliveryCustomerBankAccount] ([DCBA_Id])
);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria para obtener numero de cuenta bancaria utilizada por Forza para las transferencias.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfigurationCODByCountry', @level2type = N'COLUMN', @level2name = N'DCBAId';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primara para la obtención de nombre del banco utilizado por Forza para las transferencias.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfigurationCODByCountry', @level2type = N'COLUMN', @level2name = N'BankId';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primara para la obtención del tipo de cuenta bancaria utilizada por Forza para las transferencias.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfigurationCODByCountry', @level2type = N'COLUMN', @level2name = N'CatBankAccountTypeId';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripcion por ingresos a cuenta bancaria utilizada por Forza en su cuenta principal.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfigurationCODByCountry', @level2type = N'COLUMN', @level2name = N'InAccount';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripcion por egresos a cuenta bancaria utilizada por Forza en su cuenta principal.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfigurationCODByCountry', @level2type = N'COLUMN', @level2name = N'OutAccount';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Concepto para el ingreso a cuenta utilizada por Forza.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfigurationCODByCountry', @level2type = N'COLUMN', @level2name = N'ConceptCustomer';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Concepto de la transaccion utilizado por Forza.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfigurationCODByCountry', @level2type = N'COLUMN', @level2name = N'ConceptForza';
