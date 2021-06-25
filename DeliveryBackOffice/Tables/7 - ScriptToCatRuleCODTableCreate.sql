USE [DeliveryBackOffice]
GO

BEGIN TRAN

/****** Object:  Table [dbo].[CatRuleCOD]    Script Date: 14/06/2021 11:21:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CatRuleCOD](
	[IdCatRuleCOD] [int] IDENTITY(1,1) NOT NULL,
	[ListName] [nvarchar](50) NOT NULL,
	[Key] [nvarchar](50) NOT NULL,
	[Value] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](50) NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
 CONSTRAINT [PK_CatRuleCOD_IdCatRuleCOD] PRIMARY KEY CLUSTERED 
(
	[IdCatRuleCOD] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UK_CatRuleCOD_ListName_Key_Value] UNIQUE NONCLUSTERED 
(
	[ListName] ASC,
	[Key] ASC,
	[Value] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CatRuleCOD] ADD  CONSTRAINT [DF_CatRuleCOD_RowStatus]  DEFAULT ('TRUE') FOR [RowStatus]
GO

ALTER TABLE [dbo].[CatRuleCOD] ADD  CONSTRAINT [DF_CatRuleCOD_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO

--COMMIT


