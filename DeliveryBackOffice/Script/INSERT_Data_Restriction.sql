DECLARE @IDMODULE AS INT =  0;
SET @IDMODULE = (SELECT TOP 1 MDL_IdModule FROM [DenariusUser_Dev].[dbo].LGN_Module  where MDL_AuthPath ='fec-admin' ORDER BY MDL_IdModule DESC) ;

INSERT INTO [DeliveryBackOffice].[dbo].[Delivery_DataRestrictionByRol]
           ([DRR_IdRol]
           ,[DRR_IdCountry]
           ,[DRR_IdHubLogistic]
           ,[DRR_IdModule]
           ,[DRR_IdVisitPointClient]
           ,[DRR_Status])
     VALUES
           (873,'GT',2,@IDMODULE,4244,1),
		   (873,'GT',7,@IDMODULE,4246,1),
		    (873,'GT',1,@IDMODULE,999,1)
GO

