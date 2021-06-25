USE [DeliveryBackOffice]
GO

BEGIN TRAN

/****** Object:  Table [dbo].[CatAccountTypeCOD]    Script Date: 23/06/2021 10:15:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CatAccountTypeCOD](
	[IdCatAccountTypeCOD] [int] IDENTITY(1,1) NOT NULL,
	[AccountType] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](50) NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
 CONSTRAINT [PK_CatAccountTypeCOD_IdCatAccountTypeCOD] PRIMARY KEY CLUSTERED 
(
	[IdCatAccountTypeCOD] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UK_CatAccountTypeCOD_AccountType] UNIQUE NONCLUSTERED 
(
	[AccountType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CatAccountTypeCOD] ADD  CONSTRAINT [DF_CatAccountTypeCOD_RowStatus]  DEFAULT ('TRUE') FOR [RowStatus]
GO

ALTER TABLE [dbo].[CatAccountTypeCOD] ADD  CONSTRAINT [DF_CatAccountTypeCOD_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO

--COMMIT


