USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[SchedulePickupStatusLog]    Script Date: 09/02/2022 12:21:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SchedulePickupStatusLog](
    [IdSchedulePickupStatusLog] [bigint] IDENTITY(1,1) NOT NULL,
	[SchedulePickupId] [bigint] NOT NULL,
    [SchedulePickupStatus] [bit] NOT NULL,
    [RowStatus] [bit] NOT NULL,
    [TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
    [TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
 CONSTRAINT [PK_SchedulePickupStatusLog_IdSchedulePickupStatusLog] PRIMARY KEY CLUSTERED 
(
	[IdSchedulePickupStatusLog] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[SchedulePickupStatusLog]  WITH CHECK ADD  CONSTRAINT [FK_SchedulePickupStatusLog_SchedulePickupId] FOREIGN KEY([SchedulePickupId])
REFERENCES [dbo].[SchedulePickup] ([SchedulePickupId])
GO


ALTER TABLE [dbo].[SchedulePickupStatusLog] ADD CONSTRAINT [df_SchedulePickupStatusLog_RowStatus] DEFAULT 'TRUE' FOR RowStatus;
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID de la tabla SchedulePickupStatusLog.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchedulePickupStatusLog', @level2type=N'COLUMN',@level2name=N'IdSchedulePickupStatusLog'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID de la tabla SchedulePickup.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchedulePickupStatusLog', @level2type=N'COLUMN',@level2name=N'SchedulePickupId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Valor que se ha guardado, 1=Habilitado 0=Cancelado.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchedulePickupStatusLog', @level2type=N'COLUMN',@level2name=N'SchedulePickupStatus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado de la fila, TRUE o FALSE.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchedulePickupStatusLog', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token que creó la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchedulePickupStatusLog', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora en la que se creo la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchedulePickupStatusLog', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token que modificó la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchedulePickupStatusLog', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora en la que se creo la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchedulePickupStatusLog', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla para almacenar el log de cambio de estado a una solicitud de recolección.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchedulePickupStatusLog'
GO