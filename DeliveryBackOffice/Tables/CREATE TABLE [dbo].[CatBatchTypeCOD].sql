USE [DeliveryBackOffice]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/****** 
 **** Author: Marco, Jiménez
 **** Desc:   Se tienen la forma en que los clientes quieren que se les realice el depósito (Acumulado, Detallado-Guía por guía)
 **** Date:   12/10/2021
 ******/

CREATE TABLE [dbo].[CatBatchTypeCOD]
(
    [CatBatchTypeCODId] [bigint] IDENTITY(1, 1) NOT NULL,	
	[Name] [varchar](50) NOT NULL,	
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [varchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [varchar](50) NULL,
	[DateUpdated] [datetime] NULL,
    PRIMARY KEY CLUSTERED ([CatBatchTypeCODId] ASC)
    WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
          ALLOW_PAGE_LOCKS = ON
         ) ON [PRIMARY]
) ON [PRIMARY] 
GO

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
                                @value = N'Id para la tabla CatBatchTypeCOD ',
                                @level0type = N'SCHEMA',
                                @level0name = N'dbo',
                                @level1type = N'TABLE',
                                @level1name = N'CatBatchTypeCOD',
                                @level2type = N'COLUMN',
                                @level2name = N'CatBatchTypeCODId'
GO

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
                                @value = N'Es el nombre del tipo de formato en el que los clientes quieren que se les realice el depósito, ya sea acumulado o detallado',
                                @level0type = N'SCHEMA',
                                @level0name = N'dbo',
                                @level1type = N'TABLE',
                                @level1name = N'CatBatchTypeCOD',
                                @level2type = N'COLUMN',
                                @level2name = N'Name'
GO

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
                                @value = N'Es el estado del registro, para poder deshabilitarlo',
                                @level0type = N'SCHEMA',
                                @level0name = N'dbo',
                                @level1type = N'TABLE',
                                @level1name = N'CatBatchTypeCOD',
                                @level2type = N'COLUMN',
                                @level2name = N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
                                @value = N'Es el token de usuario con el que se insertó el registro',
                                @level0type = N'SCHEMA',
                                @level0name = N'dbo',
                                @level1type = N'TABLE',
                                @level1name = N'CatBatchTypeCOD',
                                @level2type = N'COLUMN',
                                @level2name = N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
                                @value = N'Es la fecha en la que se insertó el registro',
                                @level0type = N'SCHEMA',
                                @level0name = N'dbo',
                                @level1type = N'TABLE',
                                @level1name = N'CatBatchTypeCOD',
                                @level2type = N'COLUMN',
                                @level2name = N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
                                @value = N'Es el token de usuario con el que se actualizó el registro',
                                @level0type = N'SCHEMA',
                                @level0name = N'dbo',
                                @level1type = N'TABLE',
                                @level1name = N'CatBatchTypeCOD',
                                @level2type = N'COLUMN',
                                @level2name = N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name = N'MS_Description',
                                @value = N'Es la fecha en que se actualizó el registro',
                                @level0type = N'SCHEMA',
                                @level0name = N'dbo',
                                @level1type = N'TABLE',
                                @level1name = N'CatBatchTypeCOD',
                                @level2type = N'COLUMN',
                                @level2name = N'DateUpdated'
GO

