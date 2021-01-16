USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[RateHeader]    Script Date: 15/01/2021 23:42:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[RateHeader](
	[RheId] [int] IDENTITY(1,1) NOT NULL,
	[RheName] [varchar](200) NOT NULL,
	[RheShortName] [varchar](3) NOT NULL,
	[RheDescription] [varchar](200) NULL,
	[RheDefault] [bit] NOT NULL,
	[RheRowStatus] [bit] NOT NULL,
	[RheTokenCreated] [varchar](50) NOT NULL,
	[RheDateCreated] [datetime] NOT NULL,
	[RheTokenUpdated] [varchar](50) NULL,
	[RheCreateUpdated] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[RheId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


insert into dbo.RateHeader
values ('Tarifas Individuales','IND','Tarifas para clientes individuales',1,1,'SYS-CAQUINO',GETDATE(),NULL,NULL),
('Tarifas Corporativos','COR','Tarifas para clientes corporativos',0,1,'SYS-CAQUINO',GETDATE(),NULL,NULL)

select * from dbo.RateHeader