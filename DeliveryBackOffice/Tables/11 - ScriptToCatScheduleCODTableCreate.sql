USE [DeliveryBackOffice]
GO

BEGIN TRAN

/****** Object:  Table [dbo].[CatScheduleCOD]    Script Date: 14/06/2021 17:13:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CatScheduleCOD](
	[IdCatScheduleCOD] [int] IDENTITY(1,1) NOT NULL,
	[Hour] [time](7) NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
 CONSTRAINT [PK_CatScheduleCOD_IdCatScheduleCOD] PRIMARY KEY CLUSTERED 
(
	[IdCatScheduleCOD] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UK_CatScheduleCOD_IdCatScheduleCOD] UNIQUE NONCLUSTERED 
(
	[Hour] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CatScheduleCOD] ADD  CONSTRAINT [DF_CatScheduleCOD_RowStatus]  DEFAULT ('TRUE') FOR [RowStatus]
GO

ALTER TABLE [dbo].[CatScheduleCOD] ADD  CONSTRAINT [DF_CatScheduleCOD_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO

--COMMIT


