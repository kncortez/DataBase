
EXEC sp_rename 'ResetPasswordVerification', 'GeneratedTokens'
EXEC sp_RENAME 'GeneratedTokens.ResetTokenId' , 'TokenId', 'COLUMN'
EXEC sp_RENAME 'GeneratedTokens.VerificationDate' , 'DateOfTokenUse', 'COLUMN'

ALTER TABLE GeneratedTokens
ADD	TokenType CHAR(1)

ALTER TABLE GeneratedTokens
ADD	[IP] VARCHAR(100)

ALTER TABLE GeneratedTokens
ADD	IP VARCHAR(100)

ALTER TABLE GeneratedTokens
ADD	IdSystem INT



