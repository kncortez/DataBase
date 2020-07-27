USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[Warehouse]    Script Date: 24/07/2020 15:47:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Warehouse](
	[Id] [bigint] NOT NULL IDENTITY(1,1),
	[Rack_Position] [nvarchar](30) NOT NULL,
	[Guide_Serie] [nvarchar](2) NOT NULL,
	[Guide_Number] [int] NOT NULL,
	[Dry] [bit] NOT NULL,
	[Cold] [bit] NOT NULL,
	[Active] [bit] NOT NULL,
	[UserCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE Warehouse ADD CONSTRAINT [FK_Warehouse_DeliveryOrder] FOREIGN KEY([Guide_Serie], [Guide_Number])
REFERENCES DeliveryOrder ([Guide_Serie], [Guide_Number])

ALTER TABLE DeliveryBackOffice.dbo.DeliveryOrder DROP COLUMN Rack_Position