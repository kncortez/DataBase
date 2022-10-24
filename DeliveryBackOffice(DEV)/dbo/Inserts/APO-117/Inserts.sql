-- APO-117
INSERT INTO	[dbo].[ConfigParams]
			([Name], 
			 [Description],
			 [Value],
			 [Status],
			 [CreateDate])
VALUES		('HermesMobileVersion',
			 'Versión publicada Hermes Mobile',
			 '1.3.0',
			 1,
			 SYSDATETIME());