--SCRIPT PARA CEAR UN VISIT POINT CLIENT

DECLARE @NewCodeOfReference INT;
DECLARE @IdCustomer INT;
DECLARE @IdKindOfVPClient INT;
DECLARE @IdKindOfVPBusiness INT;
DECLARE @IdSettlement INT;
DECLARE @IdTownship INT;
DECLARE @IdSalesChannel INT;
DECLARE @IdBusinessSegment INT;

BEGIN TRY
    BEGIN TRANSACTION;
	
	SELECT TOP 1 @NewCodeOfReference = CodeOfReference FROM DeliveryBackOffice.dbo.VisitPointClient WITH(NOLOCK)
	ORDER BY IdVisitPointClient DESC --ULTIMO CODE OF REFERENCE INGRESADO

	SET @NewCodeOfReference = @NewCodeOfReference + 1; --NUEVO

	SELECT @IdCustomer = IdCustomer FROM DeliveryBackOffice.dbo.Customer WITH(NOLOCK)
	WHERE Name = 'FD EXPRESS CENTER HN' AND Description = 'FD EXPRESS CENTER HN'
	AND RowSatus = 1 AND CountryID = 'HN'

	SELECT @IdKindOfVPClient = IdKindOfVPClient FROM DeliveryBackOffice.dbo.KindOfVPClient WITH(NOLOCK)
	WHERE KindOfVPName = 'Express Center' and IdCountry = 'HN' AND KindOfVPStatus = 1

	SELECT @IdKindOfVPBusiness = IdKindOfVPBusiness FROM DeliveryBackOffice.dbo.KindOfVPBusiness WITH(NOLOCK)
	WHERE KindOfVPNameBussiness = 'EXPRESS CENTER' and IdCountry = 'HN'

	SELECT @IdSettlement = IdSettlement FROM DeliveryBackOffice.dbo.Settlement WITH(NOLOCK)
	WHERE Settlement = 'YORO'

	SELECT @IdTownship = IdTownship FROM DeliveryBackOffice.dbo.Township WITH(NOLOCK)
	WHERE TownshipName = 'YORO' AND TownshipDescription = 'YORO'

	SELECT @IdSalesChannel = IdSalesChannel FROM DeliveryBackOffice.dbo.CatSalesChannel WITH(NOLOCK)
	WHERE Description = 'Autoventa'

	SELECT @IdBusinessSegment = IdBusinessSegment FROM DeliveryBackOffice.dbo.CatBusinessSegment WITH(NOLOCK)
	WHERE BusinessSegmentName = 'C2C' AND IdCountry = 'HN' AND RowStatus = 1

	--INSERT
	INSERT INTO [dbo].[VisitPointClient]
			   ([CodeOfReference]
			   ,[DescriptionOfClient]
			   ,[StatusClient]
			   ,[CountryId]
			   ,[VisitPointId]
			   ,[TokenCreated]
			   ,[DateCreated]
			   ,[TokenUpdated]
			   ,[DateUpdated]
			   ,[CustomerID]
			   ,[Address]
			   ,[Zone]
			   ,[Town]
			   ,[Department]
			   ,[Phone]
			   ,[ContactName]
			   ,[IdKindOfVPClient]
			   ,[IdKindOfVPBusiness]
			   ,[IdSettlement]
			   ,[Email]
			   ,[IdTownship]
			   ,[Latitude]
			   ,[Longitude]
			   ,[Accuracy]
			   ,[BranchCode]
			   ,[SaleChannelId]
			   ,[ExcludePriceShippingCOD]
			   ,[ExcludeCommissionCOD]
			   ,[IsOriginVisitPoint]
			   ,[LogLatitude]
			   ,[LogLongitude]
			   ,[DescriptionCC]
			   ,[CatBusinessSegmentId]
			   ,[AllowScheduledPickups])
		 VALUES
			   (@NewCodeOfReference
			   ,'FD EXC HN 1'
			   ,1
			   ,'HN'
			   ,NULL
			   ,'SYS-WOROZCO'
			   ,'2024-08-12 17:30:00.000'
			   ,NULL
			   ,NULL
			   ,@IdCustomer
			   ,'Ciudad de Yoro'
			   ,'0'
			   ,'YORO'
			   ,'YORO'
			   ,'(+504) 2217-0098'
			   ,'FD EXC HN 1'
			   ,@IdKindOfVPClient
			   ,@IdKindOfVPBusiness
			   ,@IdSettlement
			   ,'x_exc.hn1@forzadelivery.com'
			   ,@IdTownship
			   ,'14.6386943'
			   ,'-90.5229859'
			   ,''
			   ,''
			   ,@IdSalesChannel
			   ,0
			   ,0
			   ,1
			   ,'14.638701'
			   ,'-90.5229899'
			   ,'Express Center HN 1'
			   ,@IdBusinessSegment
			   ,1)

   COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
