CREATE TABLE [dbo].[ConfigParams](
	[ConfigParamsId] [bigint] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](500) NOT NULL,
	[Description] [varchar](MAX) NULL,
	[Value] [varchar](MAX) NOT NULL,
	[Status] smallint	 NOT NULL, -- 1 ACTIVO, 0 INACTIVO
	[CreateDate] [datetime] NOT NULL,
	)

	
	ALTER TABLE [ConfigParams] ADD CONSTRAINT
DefaultDate DEFAULT GETDATE() FOR CreateDate
GO

	