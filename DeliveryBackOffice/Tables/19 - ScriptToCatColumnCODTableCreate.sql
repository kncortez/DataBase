USE [DeliveryBackOffice]
GO

BEGIN TRAN

/****** Object:  Table [dbo].[CatColumnCOD]    Script Date: 15/06/2021 10:38:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CatColumnCOD](
	[IdCatColumnCOD] [int] IDENTITY(1,1) NOT NULL,
	[ColumnName] [nvarchar](50) NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
 CONSTRAINT [PK_CatColumnCOD_IdCatColumnCOD] PRIMARY KEY CLUSTERED 
(
	[IdCatColumnCOD] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UK_CatColumnCOD_ColumnName] UNIQUE NONCLUSTERED 
(
	[ColumnName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CatColumnCOD] ADD  CONSTRAINT [DF_CatColumn_RowStatus]  DEFAULT ('TRUE') FOR [RowStatus]
GO

ALTER TABLE [dbo].[CatColumnCOD] ADD  CONSTRAINT [DF_CatColumn_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO

--COMMIT


