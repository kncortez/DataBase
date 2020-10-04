USE [DeliveryBackOffice]

/****** Object:  Table [dbo].[Incident]    Script Date: 7/09/2020 20:42:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Incident](
	[ID] [tinyint] NOT NULL,
	[Description] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_Incident] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[DeliveryAttempt] ADD ID_Incident TINYINT NULL

ALTER TABLE DeliveryAttempt ADD CONSTRAINT [FK_DeliveryAttempt_Incident] FOREIGN KEY ([ID_Incident])
REFERENCES Incident ([ID])

INSERT INTO [DeliveryBackOffice].[dbo].[Incident] (ID, [Description]) VALUES (1, 'Cliente no vive en la dirección')
INSERT INTO [DeliveryBackOffice].[dbo].[Incident] (ID, [Description]) VALUES (2, 'Dirección errónea')
INSERT INTO [DeliveryBackOffice].[dbo].[Incident] (ID, [Description]) VALUES (3, 'No hay nadie en casa')
INSERT INTO [DeliveryBackOffice].[dbo].[Incident] (ID, [Description]) VALUES (4, 'Cliente no dejó documento a persona que recibe el paquete')
INSERT INTO [DeliveryBackOffice].[dbo].[Incident] (ID, [Description]) VALUES (5, 'Servicio fuera de ruta')

INSERT INTO [DeliveryBackOffice].[dbo].[StatusOrder] (OrderDescription) VALUES ('Intento de entrega fallida')

ALTER TABLE [dbo].[DeliveryProof] ADD Proof_Incident VARBINARY(MAX) NULL