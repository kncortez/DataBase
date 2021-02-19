USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[SchedulePickup]    Script Date: 15/02/2021 12:54:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SchedulePickup](
	[SchedulePickupId] [bigint] IDENTITY(1,1) NOT NULL,
	[AccountId] [bigint] NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[EstimatedWeight] [decimal](18, 0) NULL,
	[IsLargePackage] [bit] NULL,
	[QuantityRegularPackages] [int] NULL,
	[QuantityOverDimensionedPackage] [int] NULL,
	[SpecialInstructions] [nvarchar](200) NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
	[SenderId] [int] NULL,
	[SenderName] [varchar](200) NULL,
	[SenderPhone] [varchar](50) NULL,
	[IdHubLogistics] [int] NULL,
	[AmountPickup] [decimal](12, 2) NULL,
	[IdSourcePlataform] [int] NULL,
	[AddressPickup] [varchar](500) NULL,
	[AssigmentStatus] [bit] NULL,
 CONSTRAINT [PK_SchedulePickup] PRIMARY KEY CLUSTERED 
(
	[SchedulePickupId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[SchedulePickup]  WITH CHECK ADD FOREIGN KEY([IdHubLogistics])
REFERENCES [dbo].[HubLogistics] ([IdHubLogistic])
GO

ALTER TABLE [dbo].[SchedulePickup]  WITH CHECK ADD FOREIGN KEY([IdSourcePlataform])
REFERENCES [dbo].[CatSystem] ([SysIdSystem])
GO

ALTER TABLE [dbo].[SchedulePickup]  WITH CHECK ADD FOREIGN KEY([SenderId])
REFERENCES [dbo].[VisitPointClient] ([CodeOfReference])
GO

ALTER TABLE [dbo].[SchedulePickup]  WITH CHECK ADD  CONSTRAINT [FK_SchedulePickup_Account] FOREIGN KEY([AccountId])
REFERENCES [dbo].[Account] ([AccIdAccount])
GO

ALTER TABLE [dbo].[SchedulePickup] CHECK CONSTRAINT [FK_SchedulePickup_Account]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de recolección programada' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchedulePickup', @level2type=N'COLUMN',@level2name=N'SchedulePickupId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cuenta asociada' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchedulePickup', @level2type=N'COLUMN',@level2name=N'AccountId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primer hora de recolección' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchedulePickup', @level2type=N'COLUMN',@level2name=N'StartDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Última hora de recolección' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchedulePickup', @level2type=N'COLUMN',@level2name=N'EndDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Peso estimado' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchedulePickup', @level2type=N'COLUMN',@level2name=N'EstimatedWeight'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contiene su recolección paquetes grandes?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchedulePickup', @level2type=N'COLUMN',@level2name=N'IsLargePackage'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cantidad de piezas regulares' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchedulePickup', @level2type=N'COLUMN',@level2name=N'QuantityRegularPackages'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cantidad de piezas sobredimensionadas' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchedulePickup', @level2type=N'COLUMN',@level2name=N'QuantityOverDimensionedPackage'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Instrucciones especiales' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchedulePickup', @level2type=N'COLUMN',@level2name=N'SpecialInstructions'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado del registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchedulePickup', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchedulePickup', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchedulePickup', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Usuario de actualización' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchedulePickup', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de actualización' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchedulePickup', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

