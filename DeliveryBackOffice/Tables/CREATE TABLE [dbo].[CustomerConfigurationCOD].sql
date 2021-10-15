USE [DeliveryBackOffice]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/****** 
 **** Author: Marco, Jiménez
 **** Desc:   Se tienen la configuración por cliente, para determinar, la forma en que quiere que se realicen los depósitos y la frecuencia en que los realizan
 **** Date:   12/10/2021
 ******/

CREATE TABLE [dbo].[CustomerConfigurationCOD]
(
    [CustomerConfigurationCODId] [bigint] IDENTITY(1, 1) NOT NULL,	
	[CustomerId] int NOT NULL,
	[IdCatBatchTypeCOD] [bigint] NOT NULL,	
	[IdCatBatchFrequencyCOD] [bigint] NOT NULL,	
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [varchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [varchar](50) NULL,
	[DateUpdated] [datetime] NULL,
    PRIMARY KEY CLUSTERED ([CustomerConfigurationCODId] ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
          ALLOW_PAGE_LOCKS = ON
         ) ON [PRIMARY]
) ON [PRIMARY] 
GO

ALTER TABLE [dbo].[CustomerConfigurationCOD] WITH CHECK
ADD CONSTRAINT [FK_CustomerConfigurationCOD_CustomerId]
    FOREIGN KEY ([CustomerId])
    REFERENCES [dbo].[Customer] ([IdCustomer])
GO

ALTER TABLE [dbo].[CustomerConfigurationCOD] WITH CHECK
ADD CONSTRAINT [FK_CustomerConfigurationCOD_IdCatBatchFrequencyCOD]
    FOREIGN KEY ([IdCatBatchFrequencyCOD])
    REFERENCES [dbo].[CatBatchFrequencyCOD] ([CatBatchFrequencyCODId])
GO

ALTER TABLE [dbo].[CustomerConfigurationCOD] WITH CHECK
ADD CONSTRAINT [FK_CustomerConfigurationCOD_IdCatBatchTypeCOD]
    FOREIGN KEY ([IdCatBatchTypeCOD])
    REFERENCES [dbo].[CatBatchTypeCOD] ([CatBatchTypeCODId])
GO


EXEC sys.sp_addextendedproperty @name = N'MS_Description',
                                @value = N'Id para la tabla CustomerConfigurationCOD ',
                                @level0type = N'SCHEMA',
                                @level0name = N'dbo',
                                @level1type = N'TABLE',
                                @level1name = N'CustomerConfigurationCOD',
                                @level2type = N'COLUMN',
                                @level2name = N'CustomerConfigurationCODId'
GO

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
                                @value = N'Id para la tabla Customer ',
                                @level0type = N'SCHEMA',
                                @level0name = N'dbo',
                                @level1type = N'TABLE',
                                @level1name = N'Customer',
                                @level2type = N'COLUMN',
                                @level2name = N'IdCustomer'
GO

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
                                @value = N'Id de la tabla CatBatchTypeCOD ',
                                @level0type = N'SCHEMA',
                                @level0name = N'dbo',
                                @level1type = N'TABLE',
                                @level1name = N'CustomerConfigurationCOD',
                                @level2type = N'COLUMN',
                                @level2name = N'IdCatBatchTypeCOD'
GO

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
                                @value = N'Id para la tabla CatBatchFrequencyCOD ',
                                @level0type = N'SCHEMA',
                                @level0name = N'dbo',
                                @level1type = N'TABLE',
                                @level1name = N'CustomerConfigurationCOD',
                                @level2type = N'COLUMN',
                                @level2name = N'IdCatBatchFrequencyCOD'
GO

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
                                @value = N'Es el estado del registro, para poder deshabilitarlo',
                                @level0type = N'SCHEMA',
                                @level0name = N'dbo',
                                @level1type = N'TABLE',
                                @level1name = N'CustomerConfigurationCOD',
                                @level2type = N'COLUMN',
                                @level2name = N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
                                @value = N'Es el token de usuario con el que se insertó el registro',
                                @level0type = N'SCHEMA',
                                @level0name = N'dbo',
                                @level1type = N'TABLE',
                                @level1name = N'CustomerConfigurationCOD',
                                @level2type = N'COLUMN',
                                @level2name = N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
                                @value = N'Es la fecha en la que se insertó el registro',
                                @level0type = N'SCHEMA',
                                @level0name = N'dbo',
                                @level1type = N'TABLE',
                                @level1name = N'CustomerConfigurationCOD',
                                @level2type = N'COLUMN',
                                @level2name = N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
                                @value = N'Es el token de usuario con el que se actualizó el registro',
                                @level0type = N'SCHEMA',
                                @level0name = N'dbo',
                                @level1type = N'TABLE',
                                @level1name = N'CustomerConfigurationCOD',
                                @level2type = N'COLUMN',
                                @level2name = N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
                                @value = N'Es la fecha en que se actualizó el registro',
                                @level0type = N'SCHEMA',
                                @level0name = N'dbo',
                                @level1type = N'TABLE',
                                @level1name = N'CustomerConfigurationCOD',
                                @level2type = N'COLUMN',
                                @level2name = N'DateUpdated'
GO

