CREATE TABLE [dbo].[ResetPasswordVerification](
	[ResetTokenId] [bigint] IDENTITY(1,1) NOT NULL,	
	[UserId] [bigint] NULL,
	[UserName]  VARCHAR(200) NOT NULL,
	[GeneratedToken] [varchar](200) NULL,
	[GeneratedDate] [datetime] NULL,
	[ExpirationDate] [datetime] NULL,
	[Status] [bit] NULL,
	[VerificationStatus] [bit] NULL,
	[VerificationDate] [datetime] NULL,
	[ResetCounter]  INT NOT NULL,
 CONSTRAINT [PK_ResetPasswordVerification] PRIMARY KEY CLUSTERED 
(
	[ResetTokenId] ASC
)ON [PRIMARY]
) ON [PRIMARY]
GO


