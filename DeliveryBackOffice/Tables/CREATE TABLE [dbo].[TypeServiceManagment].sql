USE [DeliveryBackOffice]
GO


/*
	TypeServiceManagment: Tabla que guarda el tipo de servicio.
*/
CREATE TABLE [dbo].[TypeServiceManagment](
	[IdTypeServiceManagment] BIGINT IDENTITY(1,1) NOT NULL,
	[Name] NVARCHAR(200) NOT NULL,
	[RowStatus] BIT NOT NULL,
	[TokenCreated] VARCHAR(150) NOT NULL,	
	[DateCreated] DATETIME NOT NULL,
	[TokenUpdated] VARCHAR(150) NULL,
	[DateUpdated] DATETIME  NULL
PRIMARY KEY CLUSTERED 
(
	[IdTypeServiceManagment] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] 
GO