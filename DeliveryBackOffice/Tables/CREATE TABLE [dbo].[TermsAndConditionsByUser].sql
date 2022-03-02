USE [DeliveryBackOffice]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TermsAndConditionsByUser](
	[IdTACByUser] [bigint] IDENTITY(1,1) NOT NULL,
	[TACId] [bigint] NOT NULL,
	[IdAccount] [bigint] NOT NULL,	
	[TAC] [BIT] NOT NULL,
	[RowStatus] [bit] NOT NULL,
	[TokenCreated] [varchar](50) NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[TokenUpdated] [varchar](50) NULL,
	[DateUpdated] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[IdTACByUser] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[TermsAndConditionsByUser]  WITH CHECK ADD FOREIGN KEY([TACId])
REFERENCES [dbo].[TermsAndConditions] ([IdTAC])
GO
ALTER TABLE [dbo].[TermsAndConditionsByUser]  WITH CHECK ADD FOREIGN KEY([IdAccount])
REFERENCES [dbo].[Account] ([AccIdAccount])
GO
GO


