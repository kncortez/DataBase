ALTER TABLE [dbo].[TokenLog]
	ADD TknReferrer VARCHAR(50) NULL

EXECUTE sp_addextendedproperty N'MS_Description', N'Host en donde se realizó el ingreso', N'SCHEMA', N'dbo', N'TABLE', N'TokenLog', N'COLUMN', N'TknReferrer'
