USE [DeliveryBackOffice]
GO

/*
	PieceByService: Guarda la pieza despachada a un servicio de entrega (Entrega, Devolución o Linehauls)
*/
CREATE TABLE [dbo].[PieceByService](
	[IdServiceManagementByPiece] BIGINT IDENTITY(1,1) NOT NULL,
	[ServiceManagmentId] INT NOT NULL,
	[GuidePieceId] BIGINT NOT NULL,
	[RowStatus] BIT NOT NULL,
	[TokenCreated] VARCHAR(150) NOT NULL,	
	[DateCreated] DATETIME NOT NULL,
	[TokenUpdated] VARCHAR(150) NULL,
	[DateUpdated] DATETIME  NULL
PRIMARY KEY CLUSTERED 
(
	[IdServiceManagementByPiece]
	ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] 
GO

ALTER TABLE [dbo].[PieceByService]  WITH NOCHECK ADD  CONSTRAINT [FK_PieceByService_ServiceManagmentId] FOREIGN KEY([ServiceManagmentId])
REFERENCES [dbo].[ServiceManagement] ([IdServiceManagement])
GO



