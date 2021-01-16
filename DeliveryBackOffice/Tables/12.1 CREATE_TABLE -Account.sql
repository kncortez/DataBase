

USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[Account]    Script Date: 7/01/2021 09:53:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Account](
	[AccIdAccount] [bigint] IDENTITY(1,1) NOT NULL,
	[AccName] [varchar](100) NOT NULL,
	[AccIdTypeAccount] [int] NOT NULL,
	[AccRowStatus] [bit] NOT NULL,
	[AccTokenCreated] [varchar](50) NOT NULL,
	[AccDateCreated] [datetime] NOT NULL,
	[AccTokenUpdated] [varchar](50) NULL,
	[AccDateUpdated] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[AccIdAccount] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Account]  WITH CHECK ADD  CONSTRAINT [FKAccountType] FOREIGN KEY([AccIdTypeAccount])
REFERENCES [dbo].[CatTypeAccount] ([TacIdTypeAccount])
GO

ALTER TABLE [dbo].[Account] CHECK CONSTRAINT [FKAccountType]
GO



INSERT INTO [dbo].[Account]
           ([AccName]
           ,[AccIdTypeAccount]
           ,[AccRowStatus]
           ,[AccTokenCreated]
           ,[AccDateCreated]
           ,[AccTokenUpdated]
           ,[AccDateUpdated])
     VALUES
           ('Envios de Cesar'
           ,1
           ,1
           ,'SYS-ADMIN'
           ,GETDATE()
           ,NULL
           ,NULL)
GO

