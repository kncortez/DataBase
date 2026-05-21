--**********************************************
--**********************************************

--NOTA:Abreviaciones Y Id's consultados en produccion

--**********************************************
--**********************************************


BEGIN TRY
	UPDATE DeliveryBackOffice.dbo.HubLogistics SET IdStation = 19,   TokenUpdate= 'SYS-BPEDROZA', DateUpdated =GETDATE() WHERE HubName= 'GUA METRO'
	UPDATE DeliveryBackOffice.dbo.HubLogistics SET IdStation =  121, TokenUpdate ='SYS-BPEDROZA', DateUpdated= GETDATE() WHERE HubAbbreviation='DEM'
	UPDATE DeliveryBackOffice.dbo.HubLogistics SET IdStation =  125, TokenUpdate ='SYS-BPEDROZA', DateUpdated= GETDATE()  WHERE HubAbbreviation = 'SLC'
	UPDATE DeliveryBackOffice.dbo.HubLogistics SET IdStation = 277, TokenUpdate ='SYS-BPEDROZA', DateUpdated= GETDATE()  WHERE HubAbbreviation='CHO'
	UPDATE DeliveryBackOffice.dbo.HubLogistics SET IdStation = 278, TokenUpdate ='SYS-BPEDROZA', DateUpdated= GETDATE()  WHERE HubAbbreviation='COM'
	UPDATE DeliveryBackOffice.dbo.HubLogistics SET IdStation = 279, TokenUpdate ='SYS-BPEDROZA', DateUpdated= GETDATE()  WHERE HubAbbreviation='DAN'
	UPDATE DeliveryBackOffice.dbo.HubLogistics SET IdStation = 280, TokenUpdate ='SYS-BPEDROZA', DateUpdated= GETDATE()  WHERE HubAbbreviation='JTI'
	UPDATE DeliveryBackOffice.dbo.HubLogistics SET IdStation = 281, TokenUpdate ='SYS-BPEDROZA', DateUpdated= GETDATE()  WHERE HubAbbreviation='LCE'
	UPDATE DeliveryBackOffice.dbo.HubLogistics SET IdStation = 282, TokenUpdate ='SYS-BPEDROZA', DateUpdated= GETDATE()  WHERE HubAbbreviation='SAP'
	UPDATE DeliveryBackOffice.dbo.HubLogistics SET IdStation = 284, TokenUpdate ='SYS-BPEDROZA', DateUpdated= GETDATE()  WHERE HubAbbreviation='SIG'
	UPDATE DeliveryBackOffice.dbo.HubLogistics SET IdStation = 283, TokenUpdate ='SYS-BPEDROZA', DateUpdated= GETDATE()  WHERE HubAbbreviation='SRO'
	UPDATE DeliveryBackOffice.dbo.HubLogistics SET IdStation = 285, TokenUpdate ='SYS-BPEDROZA', DateUpdated= GETDATE()  WHERE HubAbbreviation='TGU'
	UPDATE DeliveryBackOffice.dbo.HubLogistics SET IdStation = 286, TokenUpdate ='SYS-BPEDROZA', DateUpdated= GETDATE()  WHERE HubAbbreviation='TOC'
	UPDATE DeliveryBackOffice.dbo.HubLogistics SET IdStation = 402, TokenUpdate ='SYS-BPEDROZA', DateUpdated= GETDATE()  WHERE HubAbbreviation='CDSPS'
END TRY
BEGIN CATCH

    PRINT 'Error: ' + ERROR_MESSAGE();
    THROW;

END CATCH;