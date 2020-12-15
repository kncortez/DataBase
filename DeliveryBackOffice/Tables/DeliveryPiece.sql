USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[DeliveryPiece]    Script Date: 15/12/2020 12:09:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DeliveryPiece](
	[Guide_Serie] [nvarchar](2) NOT NULL,
	[Guide_Number] [int] NOT NULL,
	[Guide_Piece] [smallint] NOT NULL,
	[Piece_PhysicalWeight] [decimal](5, 2) NULL,
	[Piece_Category] [smallint] NULL,
	[Piece_Height] [decimal](5, 2) NULL,
	[Piece_Width] [decimal](5, 2) NULL,
	[Piece_Length] [decimal](5, 2) NULL,
	[Piece_Weight] [decimal](5, 2) NULL,
	[Piece_Created] [nvarchar](50) NOT NULL,
	[Date_Created] [datetime] NOT NULL,
	[Piece_Updated] [nvarchar](50) NULL,
	[Date_Updated] [datetime] NULL
 CONSTRAINT [PK_DeliveryPiece] PRIMARY KEY NONCLUSTERED 
(
	[Guide_Serie] ASC,
	[Guide_Number] ASC,
	[Guide_Piece] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[DeliveryPiece]  WITH CHECK ADD  CONSTRAINT [FK_DeliveryOrder_DeliveryPiece] FOREIGN KEY([Guide_Serie], [Guide_Number])
REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number])
GO

ALTER TABLE [dbo].[DeliveryPiece] CHECK CONSTRAINT [FK_DeliveryOrder_DeliveryPiece]
GO

ALTER TABLE [dbo].[DeliveryPiece]  WITH CHECK ADD  CONSTRAINT [FK_PieceCategory_DeliveryPiece] FOREIGN KEY([Piece_Category])
REFERENCES [dbo].[PieceCategory] ([Category_Id])
GO

ALTER TABLE [dbo].[DeliveryPiece] CHECK CONSTRAINT [FK_PieceCategory_DeliveryPiece]
GO
