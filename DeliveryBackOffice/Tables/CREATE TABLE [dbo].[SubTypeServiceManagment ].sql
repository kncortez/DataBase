USE [DeliveryBackOffice]
GO


/*
	[SubTypeServiceManagment]: Tabla que guarda el sub tipo de servicio.
*/
CREATE TABLE [dbo].[SubTypeServiceManagment](
	[IdSubTypeServiceManagment] BIGINT IDENTITY(1,1) NOT NULL,
	[TypeServiceManagmentId] BIGINT NOT NULL,
	[Name] NVARCHAR(200)  NULL,
	[RowStatus] BIT NOT NULL,
	[TokenCreated] VARCHAR(150) NOT NULL,	
	[DateCreated] DATETIME NOT NULL,
	[TokenUpdated] VARCHAR(150) NULL,
	[DateUpdated] DATETIME  NULL
PRIMARY KEY CLUSTERED 
(
	[IdSubTypeServiceManagment] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] 
GO

ALTER TABLE [dbo].[SubTypeServiceManagment]  WITH NOCHECK ADD  CONSTRAINT [FK_SubTypeServiceManagment_TypeServiceManagmentId] FOREIGN KEY([TypeServiceManagmentId])
REFERENCES [dbo].[TypeServiceManagment] ([IdTypeServiceManagment])
GO


