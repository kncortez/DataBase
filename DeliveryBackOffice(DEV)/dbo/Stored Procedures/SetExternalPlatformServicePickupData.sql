-- =============================================
-- Author:		<Jerson Ochoa>
-- Create date: <10-04-2023>
-- Description:	<Insertar registros de recolecciones programadas que han sido enviadas exitósamente a plataforma externa>
-- =============================================
CREATE PROCEDURE [dbo].[SetExternalPlatformServicePickupData]
	@TblSimpliroutePickup AS TblExtPlatSimpliroutePickup READONLY,
	@ServiceInputType AS INT,
	@UserToken AS NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @SimpliRoutePlatformId INT = 0;

	SET @SimpliRoutePlatformId = (	SELECT	[CEP].[IdExternalPlatform]
									FROM	[dbo].[CatExternalPlatform] CEP
									WHERE	[CEP].[NameExternalPlatform] = 'Simpliroute'
										AND	[CEP].[RowStatus] = 1);

	BEGIN TRANSACTION
	BEGIN TRY
		IF(@ServiceInputType = 1) -- VISITAS GENERADAS EXITOSAMENTE
			BEGIN
				-- TABLA AUXILIAR PARA DATOS RECIEN INSERTADOS
				DECLARE @InsertedIDs TABLE (id INT, idService INT, reference NVARCHAR(20));

				-- INSERTAR VISITAS
				INSERT DeliveryBackOffice.dbo.ExtPlatformService(
					[ExtPlatformId],
					[IdService] ,
					[Reference] ,
					[TrackingData] ,
					[Plan] ,
					[Route] ,
					[Order] ,
					[Address] ,
					[Latitude] ,
					[Longitude] ,
					[Driver] ,
					[Vehicle] ,
					[Observation] ,
					[IsIncluded] ,
					[IsDelivery] ,
					[ServiceStatus] ,
					[EstimatedTimeArrival] ,
					[RowStatus] ,
					[TokenCreated] ,
					[DateCreated],
					[IsPreLocated]
				)
				OUTPUT inserted.IdExtPlatformService,inserted.IdService,inserted.Reference INTO @InsertedIDs(id,idService,reference)
				SELECT
					@SimpliRoutePlatformId,
					[IdService] ,
					[ServiceId] ,
					[TrackingData] ,
					[PlanData] ,
					[RouteId] ,
					[OrderNo] ,
					[AddressData] ,
					[Latitude] ,
					[Longitude] ,
					[Driver],
					[Vehicle] ,
					[Observation] ,
					[IsIncluded] ,
					[IsDelivery] ,
					[ServiceStatus] ,
					[EstimatedTimeArrival] ,
					1 ,
					@UserToken ,
					GETDATE(),
					IIF([observation] IN ('2','3','4'), 1, 0)
				FROM @TblSimpliroutePickup;	
				
			END
		ELSE IF (@ServiceInputType = 2) -- VISITAS CON FALLAS (DIRECCION NO COMPRENSIBLE, NO ATENDIDAD O FILTARDAS FUERA DE RUTA)
			BEGIN
				-- TABLA AUXILIAR PARA DATOS RECIEN INSERTADOS
				DECLARE @InsertedIDs2 TABLE (id INT, guideSerie NVARCHAR(2), guideNumber INT);
				-- INSERTAR VISITAS
				INSERT DeliveryBackOffice.dbo.ExtPlatformService(
				[ExtPlatformId],
				[IdService] ,
				[Reference] ,
				[Plan] ,
				[Address] ,
				[Latitude] ,
				[Longitude] ,
				[Observation] ,
				[IsIncluded] ,
				[IsDelivery] ,
				[ServiceStatus] ,
				[RowStatus] ,
				[TokenCreated] ,
				[DateCreated]
			)
			OUTPUT inserted.IdExtPlatformService,LEFT(inserted.Reference,2),SUBSTRING(inserted.Reference,3,LEN(inserted.Reference)) INTO @InsertedIDs2(id,guideSerie,guideNumber)
			SELECT
				@SimpliRoutePlatformId,
				0 ,
				[ServiceId],
				[PlanData] ,
				[AddressData] ,
				[Latitude] ,
				[Longitude] ,
				[observation] ,
				[IsIncluded] ,
				[IsDelivery] ,
				'notIncluded' ,
				1 ,
				@UserToken ,
				GETDATE()
			FROM @TblSimpliroutePickup ;
			END
    
		-- ACTUALIZAR REGISTRO EN TABLA ExternalPlatformPickupServiceLog
		UPDATE		[EPPSL]
		SET			[EPPSL].[IsInExternalPlatform] = 1
		FROM		[dbo].[ExternalPlatformPickupServiceLog] EPPSL
		INNER JOIN	@TblSimpliroutePickup TSRP
			ON		[EPPSL].[ServiceManagementId] = [TSRP].[ServiceId];

		IF @@TRANCOUNT > 0
			BEGIN
				COMMIT TRANSACTION;
				SELECT
					1 AS 'StatusCode',
					'Registros guardados correctamente' AS 'Description';
			END
	END TRY
	BEGIN CATCH
		SELECT
			0 AS 'StatusCode',
			ERROR_MESSAGE() AS 'Description';
		ROLLBACK TRANSACTION;
	END CATCH
END