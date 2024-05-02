
UPDATE [DeliveryBackOffice].[dbo].[tb_StringEncoding]
	SET StringReplacement = '\u007B'
WHERE StringToReplace='{';

UPDATE [DeliveryBackOffice].[dbo].[tb_StringEncoding]
	SET StringReplacement = '\u007D'
WHERE StringToReplace='}';
