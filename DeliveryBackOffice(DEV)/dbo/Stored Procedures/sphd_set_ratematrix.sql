-- =============================================
-- Author:		<Alberto,Ixchop>
-- Create date: <2022-01-06>
-- Description:	<Crea o modifica una tarifa para un hub origen y un hub destino perteneciente a un tarifario estandar>
-- =============================================
CREATE PROCEDURE sphd_set_ratematrix 
	@idHubSource int,
	@idHubDestiny int,
	@idRate int ,
	@TypeService VARCHAR(3),	--SDD|NDD|TDA
	@ratevalue decimal(14,2),
	@tokenuser nvarchar(50)
AS
BEGIN
	DECLARE @ACTIONDONE NVARCHAR(50);	--Flag that indicates what action was carried out (RECORD CREATED | UPDATED)
	DECLARE @RowCount INTEGER=0;		--Indicates how many rows were modified
	DECLARE @idTypeService INTEGER=(SELECT CtsId FROM DBO.CatTypeService WHERE CtsShortName=@TypeService); --Gets the id of the service type
	BEGIN TRANSACTION
	BEGIN TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF @idTypeService IS NULL
		RAISERROR(N'No existe el tipo de servicio especificado', 10, -1)

	--Checking if the rate already exists searching by HubSource,HubDestiny
    IF EXISTS (select * from dbo.RateData WHERE RateId=@idRate AND HubSourceId=@idHubSource AND HubDestinyId=@idHubDestiny AND TypeServiceId=@idTypeService AND RowStatus=1) 
    BEGIN
    	--RATE EXIST THEN UPDATE RATE
    	update dbo.RateData set 
			RateValue=(case when @ratevalue  is null then  RateValue else @ratevalue end),
			TokenUpdated=@tokenuser,
			DateUpdated=GETDATE(),
			RowStatus=(case when @ratevalue  is null then 0 else RowStatus end)
		where 
    		RateId=@idRate					--IdTarifario
    		and TypeServiceId=@idTypeService	--IdTipo de servicio
    		and ((HubSourceId=@idHubSource and HubDestinyId=@idHubDestiny)or(HubSourceId=@idHubDestiny and HubDestinyId=@idHubSource))
    		and RowStatus=1;					--Registro activ
		SET @ACTIONDONE='UPDATED';
		SET @RowCount=@@ROWCOUNT;
    END
    ELSE IF (@ratevalue IS NOT NULL)
    BEGIN
    	--RATE NOT EXIST THEN CREATE RATE
    	INSERT INTO DBO.RateData 
    	(
    		RateId,
    		TypeServiceId,
    		TypeSegmentId,
    		HubSourceId,
    		HubDestinyId,
    		ArticleId,
    		RateValue,
    		RowStatus,
    		TokenCreated,
    		DateCreated,
    		TokenUpdated,
    		DateUpdated,
    		LimitHourDelivery,
    		LimitHourPickup		
    	)values
    	(
    		@idRate,
    		@idTypeService,
    		NULL,
    		@idHubSource,
    		@idHubDestiny,
    		NULL,
    		@ratevalue,
    		1,
    		@tokenuser,
    		GETDATE(),
    		NULL,
    		NULL,
    		NULL,
    		NULL
    	);
		--If Source an Destiny are not the same, save inverted pair, example  (GUA,GTM)(GTM,GUA)
		IF @idHubSource <>@idHubDestiny
    	INSERT INTO DBO.RateData 
    	(
    		RateId,
    		TypeServiceId,
    		TypeSegmentId,
    		HubSourceId,
    		HubDestinyId,
    		ArticleId,
    		RateValue,
    		RowStatus,
    		TokenCreated,
    		DateCreated,
    		TokenUpdated,
    		DateUpdated,
    		LimitHourDelivery,
    		LimitHourPickup		
    	)values
    	(
    		@idRate,
    		@idTypeService,
    		NULL,
    		@idHubDestiny,
    		@idHubSource,
    		NULL,
    		@ratevalue,
    		1,
    		@tokenuser,
    		GETDATE(),
    		NULL,
    		NULL,
    		NULL,
    		NULL
    	)
		SET @ACTIONDONE='CREATED';
		SET @RowCount=@@ROWCOUNT;
    END
		COMMIT TRANSACTION;
		SELECT 'TRUE'	[blnResult]
			,NULL AS [ErrorNumber]
			,NULL AS [ErrorSeverity]
			,NULL AS [ErrorState]
			,NULL AS [ErrorProcedure]
			,@RowCount AS [ErrorLine]  
			,@ACTIONDONE   AS [Message];  	
	END TRY
	BEGIN CATCH  
			SELECT 'FALSE'	[blnResult]
				,CAST(ERROR_NUMBER() AS VARCHAR) AS [ErrorNumber]
				,CAST(ERROR_SEVERITY() AS VARCHAR) AS [ErrorSeverity]
				,CAST(ERROR_STATE() AS VARCHAR) AS [ErrorState]
				,CAST(ERROR_PROCEDURE() AS VARCHAR) AS [ErrorProcedure]
				,CAST(ERROR_LINE() AS VARCHAR) AS [ErrorLine]  
				,CAST(ERROR_MESSAGE() AS NVARCHAR(MAX)) AS [Message];  
			ROLLBACK TRANSACTION;  
	END CATCH;  
END
