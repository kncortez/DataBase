USE [DeliveryBackOffice]
GO

/****** Object:  Table [dbo].[CatCountry]    Script Date: 1/23/2021 5:01:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CatCountry](
	[IdCountry] [varchar](2) NOT NULL,
	[CountryNameEN] [varchar](55) NULL,
	[CountryNameES] [varchar](55) NULL,
	[CountryAlpha3Code] [varchar](3) NULL,
	[CountryNationality] [varchar](50) NULL,
	[CountryRowStatus] [bit] NULL,
	[CountryTokenCreated] [varchar](50) NULL,
	[CountryDateCreated] [datetime] NOT NULL,
	[CountryTokenUpdated] [varchar](50) NULL,
	[CountryDateUpdated] [datetime] NULL,
 CONSTRAINT [PK_CatCountry] PRIMARY KEY CLUSTERED 
(
	[IdCountry] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CatCountry] ADD  CONSTRAINT [DF_CatCountry_CountryRowStatus]  DEFAULT ('TRUE') FOR [CountryRowStatus]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ISO Code 3166 Alpha2Code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatCountry', @level2type=N'COLUMN',@level2name=N'IdCountry'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ISO Code 3166 Alpha3Code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatCountry', @level2type=N'COLUMN',@level2name=N'CountryAlpha3Code'
GO


