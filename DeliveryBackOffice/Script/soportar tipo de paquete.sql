USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[Package]    Script Date: 20/06/2020 19:20:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Package](
	[Package_Type] [tinyint] NOT NULL,
	[Package_Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Package] PRIMARY KEY CLUSTERED 
(
	[Package_Type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


insert into DeliveryBackOffice.dbo.Package values (1, 'Sobre')
insert into DeliveryBackOffice.dbo.Package values (2, 'Caja')

ALTER TABLE deliveryBackOffice.dbo.DeliveryOrder ADD Package_Type TINYINT NULL

ALTER TABLE deliveryBackOffice.dbo.DeliveryOrder ADD CONSTRAINT FK_PackageType FOREIGN KEY (Package_Type) REFERENCES Package(Package_Type)

--UPDATE deliveryBackOffice.dbo.DeliveryOrder SET Package_Type = 1 WHERE Guide_Number IN (5405,5404)