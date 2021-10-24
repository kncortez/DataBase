USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[CatExternalPlatform]    Script Date: 16/08/2021 13:29:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER TABLE [dbo].[SMS_Sent]
ADD COLUMN [SentTypeStatus] [int] NULL
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo de envio realizado (NULL o 0 = sin enviar; 1 = enviado recoleccion; 2 = enviado arribo instalaciones)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SMS_Sent', @level2type=N'COLUMN',@level2name=N'SentTypeStatus'
GO




