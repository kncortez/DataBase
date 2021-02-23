BEGIN TRAN
USE [DeliveryBackOffice]
GO
INSERT INTO [dbo].[RateByHub]
           ([RbhIdRate]
           ,[RbhIdHubSource]
           ,[RbhIdHubDestiny]
           ,[RbhIdTypeService]
           ,[RbhRate]
           ,[RbhFragileRate]
           ,[RbhInsuranceRate]
           ,[RbhCollectedRate]
           ,[RbhWeightAdditionalRate]
           ,[RbhWeightLimit]
           ,[RbhWeightMeasure]
           ,[RbhDeliveryAttempts]
           ,[RbhCurrency]
           ,[RbhRowStatus]
           ,[RbhTokenCreated]
           ,[RbhDateCreated]
           )
     VALUES
	  /*guatemala - guatemala */
           (1
           ,(select G.IdHubLogistic from HubLogistics G where UPPER(G.HubName)  = 'CENTRAL' AND G.HubStatus = 1)			--ORIGEN
           ,(select G.IdHubLogistic from HubLogistics G where UPPER(G.HubName)  = 'CENTRAL' AND G.HubStatus = 1)			--DESTINO 
           ,1								
           ,'25.00'							
           ,'00.00'							
           ,'00.00'							
           ,'03.00'							
           ,'01.00'							
           ,'30'							
           ,'LBS'							
           ,'3'								
           ,'GTQ'							
           ,'1'								
           ,'SYS-CAQUINO'					
           ,(SELECT GETDATE())				
           ),/*Guatemala A GUATEMETRO*/
		   (1
           ,(select G.IdHubLogistic from HubLogistics G where UPPER(G.HubName)  = 'CENTRAL' AND G.HubStatus = 1)			--ORIGEN
           ,(select G.IdHubLogistic from HubLogistics G where UPPER(G.HubName)  = 'GUA METRO' AND G.HubStatus = 1)			--DESTINO 
           ,1								
           ,'28.00'							
           ,'00.00'							
           ,'00.00'							
           ,'03.00'							
           ,'01.00'							
           ,'30'							
           ,'LBS'							
           ,'3'								
           ,'GTQ'							
           ,'1'								
           ,'SYS-CAQUINO'					
           ,(SELECT GETDATE())				
           )
		   ,/*gua meto a Guate*/
		   (1
           ,(select G.IdHubLogistic from HubLogistics G where UPPER(G.HubName)  = 'GUA METRO' AND G.HubStatus = 1)			--ORIGEN
           ,(select G.IdHubLogistic from HubLogistics G where UPPER(G.HubName)  = 'CENTRAL' AND G.HubStatus = 1)			--DESTINO 
           ,1								
           ,'28.00'							
           ,'00.00'							
           ,'00.00'							
           ,'03.00'							
           ,'01.00'							
           ,'30'							
           ,'LBS'							
           ,'3'								
           ,'GTQ'							
           ,'1'								
           ,'SYS-CAQUINO'					
           ,(SELECT GETDATE())				
           ),
		   /*gua meto a Gua metro*/
		   (1
           ,(select G.IdHubLogistic from HubLogistics G where UPPER(G.HubName)  = 'GUA METRO' AND G.HubStatus = 1)			
           ,(select G.IdHubLogistic from HubLogistics G where UPPER(G.HubName)  = 'GUA METRO' AND G.HubStatus = 1)			 
           ,1								
           ,'28.00'							
           ,'00.00'							
           ,'00.00'							
           ,'03.00'							
           ,'01.00'							
           ,'30'							
           ,'LBS'							
           ,'3'								
           ,'GTQ'							
           ,'1'								
           ,'SYS-CAQUINO'					
           ,(SELECT GETDATE())				
           )
GO
COMMIT 
