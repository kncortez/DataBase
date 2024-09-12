USE DeliveryBackOffice
GO

BEGIN TRANSACTION
BEGIN TRY
	INSERT INTO ConfigParams VALUES
	('UrlNetWork'	,'Url de facebook'	        ,'https://www.facebook.com/forzadeliveryexpress?mibextid=ZbWKwL'	        ,1	,GETDATE(),	'GT',	NULL),
	('UrlNetWork'	,'Url de instagram'	        ,'https://www.instagram.com/forzadeliveryexpress?igsh=MTVvNGE2d2loemp4Zw=='	,1	,GETDATE(),	'GT',	NULL),
	('UrlNetWork'	,'Url de Linkedin'	        ,'https://www.linkedin.com/company/forza-delivery-express/'	                ,1	,GETDATE(),	'GT',	NULL),
	('UrlNetWork'	,'Url de Whatsapp'	        ,'https://api.whatsapp.com/send?phone=50223775377'	                        ,1	,GETDATE(),	'GT',	NULL),
	('PBX'	        ,'Numero de telefono'	    ,'1753'	                                                                    ,1	,GETDATE(),	'GT',	NULL),
	('UrlNetWork'	,'Url de facebook'  	,'https://www.facebook.com/forzadeliveryexpress?mibextid=ZbWKwL'	            ,1	,GETDATE(),	'HN',	NULL),
	('UrlNetWork'	,'Url de instagram' 	,'https://www.instagram.com/forzadeliveryexpress?igsh=MTVvNGE2d2loemp4Zw=='	    ,1	,GETDATE(),	'HN',	NULL),
	('UrlNetWork'	,'Url de Linkedin'  	,'https://www.linkedin.com/company/forza-delivery-express/'	                    ,1	,GETDATE(),	'HN',	NULL),
	('UrlNetWork'	,'Url de Whatsapp'  	,'https://api.whatsapp.com/send?phone=50223775377'	                            ,1	,GETDATE(),	'HN',	NULL),
	('PBX'	        ,'Numero de telefono'   ,'1754'	                                                                        ,1	,GETDATE(),	'HN',	NULL)
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
END CATCH

