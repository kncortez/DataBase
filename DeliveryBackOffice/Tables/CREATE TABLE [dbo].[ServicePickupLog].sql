USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[ServicePickupLog]    Script Date: 31/01/2022 12:21:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ServicePickupLog](
    [IdServicePickupLog] [bigint] IDENTITY(1,1) NOT NULL,
	[GuideSerie] [nvarchar](2) NOT NULL,
	[GuideNumber] [int] NOT NULL,
    [OldIdHeaderRecolection] [int] NOT NULL,
    [NewIdHeaderRecolection] [int] NOT NULL,
    [RowStatus] [bit] NOT NULL,
    [TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
    [TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
 CONSTRAINT [PK_ServicePickupLog_IdServicePickupLog] PRIMARY KEY CLUSTERED 
(
	[IdServicePickupLog] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ServicePickupLog] ADD CONSTRAINT [df_ServicePickupLog_RowStatus] DEFAULT 'TRUE' FOR RowStatus;
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID de la tabla ServicePickupLog.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServicePickupLog', @level2type=N'COLUMN',@level2name=N'IdServicePickupLog'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Serie de la guía.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServicePickupLog', @level2type=N'COLUMN',@level2name=N'GuideSerie'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Número de la guía.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServicePickupLog', @level2type=N'COLUMN',@level2name=N'GuideNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'IdHeaderRecolection que tenía asignado en la tabla DeliveryOrderPaymentDetail.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServicePickupLog', @level2type=N'COLUMN',@level2name=N'OldIdHeaderRecolection'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nuevo IdHeaderRecolection a asignar en la tabla DeliveryOrderPaymentDetail.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServicePickupLog', @level2type=N'COLUMN',@level2name=N'NewIdHeaderRecolection'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado de la fila, TRUE o FALSE.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServicePickupLog', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token que creó la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServicePickupLog', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora en la que se creo la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServicePickupLog', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token que modificó la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServicePickupLog', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha y hora en la que se creo la fila.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServicePickupLog', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla para almacenar el log de la reasignación de servicios de recolección.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServicePickupLog'
GO