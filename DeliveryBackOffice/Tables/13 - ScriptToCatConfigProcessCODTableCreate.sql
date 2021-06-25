USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[CatConfigProcessCOD]    Script Date: 14/06/2021 17:32:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CatConfigProcessCOD](
	[IdCatConfigProcessCOD] [int] IDENTITY(1,1) NOT NULL,
	[CatProcessCODId] [int] NOT NULL,
	[CatScheduleCODId] [int] NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
 CONSTRAINT [PK_CatConfigProcessCOD_IdCatConfigProcessCOD] PRIMARY KEY CLUSTERED 
(
	[IdCatConfigProcessCOD] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UK_CatConfigProcessCOD_CatProcessCODId_CatScheduleCODId] UNIQUE NONCLUSTERED 
(
	[CatProcessCODId] ASC,
	[CatScheduleCODId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CatConfigProcessCOD] ADD  CONSTRAINT [DF_CatConfigProcessCOD_RowStatus]  DEFAULT ('TRUE') FOR [RowStatus]
GO

ALTER TABLE [dbo].[CatConfigProcessCOD] ADD  CONSTRAINT [DF_CatConfigProcessCOD_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO

ALTER TABLE [dbo].[CatConfigProcessCOD]  WITH CHECK ADD  CONSTRAINT [FK_CatProcessCOD_IdCatProcessCOD_CatConfigProcessCOD_CatProcessCODId] FOREIGN KEY([CatProcessCODId])
REFERENCES [dbo].[CatProcessCOD] ([IdCatProcessCOD])
GO

ALTER TABLE [dbo].[CatConfigProcessCOD] CHECK CONSTRAINT [FK_CatProcessCOD_IdCatProcessCOD_CatConfigProcessCOD_CatProcessCODId]
GO

ALTER TABLE [dbo].[CatConfigProcessCOD]  WITH CHECK ADD  CONSTRAINT [FK_CatScheduleCOD_IdCatScheduleCOD_CatConfigProcessCOD_CatScheduleCODId] FOREIGN KEY([CatScheduleCODId])
REFERENCES [dbo].[CatScheduleCOD] ([IdCatScheduleCOD])
GO

ALTER TABLE [dbo].[CatConfigProcessCOD] CHECK CONSTRAINT [FK_CatScheduleCOD_IdCatScheduleCOD_CatConfigProcessCOD_CatScheduleCODId]
GO


