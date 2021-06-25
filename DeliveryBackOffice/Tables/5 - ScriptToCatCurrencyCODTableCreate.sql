USE [DeliveryBackOffice]
GO

BEGIN TRAN

/****** Object:  Table [dbo].[CatCurrencyCOD]    Script Date: 14/06/2021 10:43:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CatCurrencyCOD](
	[IdCatCurrencyCOD] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Symbol] [nvarchar](3) NULL,
	[CodeISO] [nvarchar](3) NOT NULL,
	[NumISO] [int] NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [nvarchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [nvarchar](50) NULL,
	[DateUpdated] [datetime] NULL,
 CONSTRAINT [PK_CatCurrencyCOD_IdCatCurrencyCOD] PRIMARY KEY CLUSTERED 
(
	[IdCatCurrencyCOD] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UK_CatCurrencyCOD_Name_CodeISO_NumISO] UNIQUE NONCLUSTERED 
(
	[Name] ASC,
	[CodeISO] ASC,
	[NumISO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CatCurrencyCOD] ADD  CONSTRAINT [DF_CatCurrencyCOD_RowStatus]  DEFAULT ('TRUE') FOR [RowStatus]
GO

ALTER TABLE [dbo].[CatCurrencyCOD] ADD  CONSTRAINT [DF_CatCurrencyCOD_DateCreated]  DEFAULT (getdate()) FOR [DateCreated]
GO

--COMMIT


