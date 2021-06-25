USE [DeliveryBackOffice]
GO

BEGIN TRAN

/****** Object:  Table [dbo].[CatConceptCOD]    Script Date: 23/06/2021 11:09:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CatConceptCOD](
	[IdCatConceptCOD] [int] IDENTITY(1,1) NOT NULL,
	[Concept] [nvarchar](50) NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
 CONSTRAINT [PK_CatConceptCOD_IdCatConceptCOD] PRIMARY KEY CLUSTERED 
(
	[IdCatConceptCOD] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UK_CatConceptCOD_Concept] UNIQUE NONCLUSTERED 
(
	[Concept] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CatConceptCOD] ADD  CONSTRAINT [DF_CatConceptCOD_RowStatus]  DEFAULT ('TRUE') FOR [RowStatus]
GO

ALTER TABLE [dbo].[CatConceptCOD] ADD  CONSTRAINT [DF_CatConceptCOD_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO

--COMMIT


