USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[SchedulePickupDuplicateLog]    Script Date: 10/06/2022 05:19:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SchedulePickupDuplicateLog](
	[IdSchedulePickupDuplicateLog] [bigint] IDENTITY(1,1) NOT NULL,
	[SchedulePickupIdOld] [bigint] NOT NULL,
	[SchedulePickupIdNew] [bigint] NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
 CONSTRAINT [PK_SchedulePickupDuplicateLog_IdSchedulePickupDuplicateLog] PRIMARY KEY CLUSTERED 
(
	[IdSchedulePickupDuplicateLog] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[SchedulePickupDuplicateLog]  WITH CHECK ADD  CONSTRAINT [FK_SchedulePickupDuplicateLog_SchedulePickupIdOld] FOREIGN KEY([SchedulePickupIdOld])
REFERENCES [dbo].[SchedulePickup] ([SchedulePickupId])
GO

ALTER TABLE [dbo].[SchedulePickupDuplicateLog] CHECK CONSTRAINT [FK_SchedulePickupDuplicateLog_SchedulePickupIdOld]
GO

ALTER TABLE [dbo].[SchedulePickupDuplicateLog]  WITH CHECK ADD  CONSTRAINT [FK_SchedulePickupDuplicateLog_SchedulePickupIdNew] FOREIGN KEY([SchedulePickupIdNew])
REFERENCES [dbo].[SchedulePickup] ([SchedulePickupId])
GO

ALTER TABLE [dbo].[SchedulePickupDuplicateLog] CHECK CONSTRAINT [FK_SchedulePickupDuplicateLog_SchedulePickupIdNew]
GO


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID de la tabla SchedulePickupDuplicateLog.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchedulePickupDuplicateLog', @level2type=N'COLUMN',@level2name=N'IdSchedulePickupDuplicateLog'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SchedulePickupId del servicio que se está duplicando.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchedulePickupDuplicateLog', @level2type=N'COLUMN',@level2name=N'SchedulePickupIdOld'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'SchedulePickupId del servicio duplicado.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchedulePickupDuplicateLog', @level2type=N'COLUMN',@level2name=N'SchedulePickupIdNew'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado de la fila, TRUE o FALSE.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchedulePickupDuplicateLog', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token que creó la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchedulePickupDuplicateLog', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora en la que se creo la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchedulePickupDuplicateLog', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token que modificó la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchedulePickupDuplicateLog', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora en la que se creo la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchedulePickupDuplicateLog', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla para almacenar el log de confirmación de duplicar servicios de recolección.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchedulePickupDuplicateLog'
GO


