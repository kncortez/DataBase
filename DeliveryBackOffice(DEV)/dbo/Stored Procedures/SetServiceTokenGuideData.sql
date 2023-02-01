-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-01-03>
-- Description:	< Actualiza información de servicio para guía.>
-- =============================================
-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-01-03>
-- Description:	< Se remueve el poder modificar departamento y municipio ya que puede causar revalorizaciones. >
-- =============================================
CREATE PROCEDURE [dbo].[SetServiceTokenGuideData]
	@GuideSerie NVARCHAR(2) = '',
	@GuideNumber INT = -1,
	@GuideToken NVARCHAR(50),
	@Latitude DECIMAL(18,15),
	@Longitude DECIMAL(18,15),
	@StartTime NVARCHAR(20),
	@EndTime NVARCHAR(20),

	@NewProvince NVARCHAR(100) = '',
	@NewTown NVARCHAR(100) = '',
	@NewZone NVARCHAR(100) = '',
	@NewAddress NVARCHAR(600) = '',
	@NewTownshipID INT = -1,
	@NewSettlementID BIGINT = -1,

	@DeliveryAttemptId INT = NULL,
	@RoutePreparationId INT = NULL,
	@DeliverySettlementId INT = NULL,

	@SetIncidence BIT = 0,
	@IncidenceType INT = NULL,

	@SetReschedule BIT = 0,
	@RescheduleDate DATE = NULL,
	@IsConfirmed BIT = 1
AS
BEGIN

	-- Variables de apoyo
	DECLARE @TokenGuideSerie NVARCHAR(2);
	DECLARE @TokenGuideNumber INT;

	-- Variables de control de flujo
	DECLARE @IsDeliveryOnRoute AS BIT = 0;
	DECLARE @IsDelivery AS BIT = 0;
	DECLARE @IsPickup AS BIT = 0;
	DECLARE @IsVisitPoint AS BIT = 0;
	DECLARE @VisitPointExists AS BIT = 0;

	-- Variables de control de cambios
	DECLARE @UpdatedRP BIT = 0;
	DECLARE @UpdatedDA BIT = 0;
	DECLARE @UpdatedSDFG BIT = 0;
	DECLARE @UpdatedDO BIT = 0;
	DECLARE @UpdatedVPC BIT = 0;

	DECLARE @StatusOrderId TINYINT
	DECLARE @CatTypeConfirmationOfIncidenceId INT

	-- Variables de respuesta
	DECLARE @jsonResult NVARCHAR(MAX);
	
	SET @IsDelivery = (
		SELECT TOP 1 (CASE WHEN SDFG.[IsDelivery] = 1 AND SDFG.IsInRoute = 0 THEN 1 ELSE 0 END) 
		FROM [dbo].[ServiceDataForGuide] SDFG WITH(NOLOCK)
		WHERE SDFG.GuideToken = @GuideToken
		ORDER BY SDFG.DateCreated DESC
	);
	
	SET @IsDeliveryOnRoute = (
		SELECT TOP 1 (CASE WHEN SDFG.[IsDelivery] = 1 AND SDFG.IsInRoute = 1 THEN 1 ELSE 0 END) 
		FROM [dbo].[ServiceDataForGuide] SDFG WITH(NOLOCK)
		WHERE SDFG.GuideToken = @GuideToken
		ORDER BY SDFG.DateCreated DESC
	);

	IF (@IsDeliveryOnRoute = 1)
	BEGIN
		BEGIN TRANSACTION
		BEGIN TRY

			SELECT
				@TokenGuideSerie = SDFG.GuideSerie
				,@TokenGuideNumber = SDFG.GuideNumber
			FROM
				[DeliveryBackOffice].[dbo].[ServiceDataForGuide] SDFG WITH(NOLOCK)
			WHERE
				SDFG.GuideToken = @GuideToken

			UPDATE 
				SDFG
			SET 
				DateUsed = GETDATE(),
				Latitude = @Latitude,
				Longitude = @Longitude,
				ProviderModule = (SELECT [ModIdModule] FROM [CatModule] WHERE [ModName]LIKE'%Landing Delivery Page%'),
				TokenUpdated = 'SYS-HERMESROUTESLanding',
				DateUpdated = GETDATE()
			FROM [dbo].[ServiceDataForGuide] SDFG WITH(NOLOCK)
			WHERE SDFG.GuideToken = @GuideToken

			IF @@ROWCOUNT > 0
			BEGIN
				SET @UpdatedSDFG = 1
			END
		
			-- Si se altera la dirección del servicio 
			IF( ISNULL(@NewAddress,'')!='' )
			BEGIN
				UPDATE [dbo].[DeliveryOrder]
				SET 
					Receiver_Address = @NewAddress
					,Receiver_Zone = IIF( ISNULL(@NewZone,'')!='', @NewZone, Receiver_Zone )
				FROM [dbo].[ServiceDataForGuide] SDFG WITH(NOLOCK)
				INNER JOIN [dbo].[DeliveryOrder] DO WITH(NOLOCK)
				ON DO.Guide_Serie = SDFG.GuideSerie AND DO.Guide_Number = SDFG.GuideNumber
				WHERE SDFG.GuideToken = @GuideToken
				AND SDFG.IsDelivery = 1

			END

			IF (ISNULL(@SetIncidence, 0) = 1)
			BEGIN

				-- Marcar guía como incidencia
				UPDATE
					DA
				SET
					DA.ID_Incident = @IncidenceType
				FROM
					[DeliveryBackOffice].[dbo].[DeliveryAttempt] DA WITH(NOLOCK)
				WHERE
					DA.ID = @DeliveryAttemptId

					
				IF @@ROWCOUNT > 0
				BEGIN
					SET @UpdatedDA = 1
				END
		
				-- actualizar tabla de registro de guías electrónicas
				UPDATE DeliveryBackOffice.dbo.DeliveryOrder
				SET StatusOrderId = 12
				WHERE Guide_Serie = @TokenGuideSerie
					  AND Guide_Number = @TokenGuideNumber;

				--- Actualizar el estado de las piezas
				UPDATE [DeliveryBackOffice].[dbo].[DeliveryOrderPiece]
				SET StatusOrderId = 12
				WHERE GuideSerie = @TokenGuideSerie
					  AND GuideNumber = @TokenGuideNumber;

				-- registrar estado en tabla de checkpoints
				INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail
				(
					Guide_Serie,
					Guide_Number,
					StatusOrderId,
					UserCreated,
					DateCreated,
					DateCreatedInSystem,
					Observations,
					Temperature_Celsius
				)
				VALUES
				(
					@TokenGuideSerie
					,@TokenGuideNumber
					,12
					,'SYS-HERMESROUTESLanding'
					,GETDATE()
					,GETDATE()
					,NULL
					,NULL
				);

				IF(ISNULL(@SetReschedule,0) = 1)
				BEGIN
				
					DECLARE @OriginRouteId INT;

					SELECT
						@OriginRouteId = RP.CatRouteId
					FROM
						[DeliveryBackOffice].[dbo].[RoutePreparation] RP WITH(NOLOCK)
					WHERE
						RP.IdRoutePreparation = @RoutePreparationId

					DECLARE @NewRoutePreparation INT = 0;
					DECLARE @NewRouteManifest INT = 0;

					SELECT 
						@NewRoutePreparation = COALESCE(IdRoutePreparation,0),
						@NewRouteManifest = COALESCE(DeliveryOrderBySettlementId,0)
					FROM [DeliveryBackOffice].[dbo].RoutePreparation RP WITH(NOLOCK)
					WHERE 
						CatRouteId = @OriginRouteId 
						AND 
						DateRoutePreparation = @RescheduleDate 
						AND 
						RowStatus = 1

					DECLARE @InsertedRoutePreparation TABLE (
						IdRoutePreparation INT
					)
					DECLARE @InsertedRoutePreparationDetail TABLE (
						IdRoutePreparationDetail INT
					)

					IF(@NewRouteManifest = 0)
					BEGIN

						IF (@NewRoutePreparation = 0)
						BEGIN

							--- Ingresar nueva preparación de ruta por reasignación 
							INSERT INTO [dbo].[RoutePreparation]
								(
								   [CatRouteId]
								   ,[DateRoutePreparation]
								   ,[GuidesQuantity]
								   ,[PiecesDry]
								   ,[PiecesCold]
								   ,[RowStatus]
								   ,[TokenCreated]
								   ,[DateCreated]
								   ,[TokenUpdated]
								   ,[DateUpdated]
								)
							OUTPUT inserted.IdRoutePreparation INTO @InsertedRoutePreparation (IdRoutePreparation)
							 VALUES
								(
								   @OriginRouteId
								   ,@RescheduleDate
								   ,1
								   ,0
								   ,0
								   ,1
								   ,'SYS-HERMESROUTESLanding'
								   ,GETDATE()
								   ,NULL
								   ,NULL
								)

							SELECT
								TOP 1
									@NewRoutePreparation = IdRoutePreparation
							FROM
								@InsertedRoutePreparation

						END

						IF(
							ISNULL(@NewRoutePreparation,0) > 0 
							AND 
							NOT EXISTS 
								(
									SELECT 
										TOP 1 
											1 
									FROM 
										[DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD WITH(NOLOCK)
										INNER JOIN
											[DeliveryBackOffice].[dbo].RoutePreparation RP WITH(NOLOCK)
											ON
												RPD.RoutePreparationId = RP.IdRoutePreparation
												AND
												RP.DateRoutePreparation = @RescheduleDate
									WHERE 
										RPD.Guide_Serie = @TokenGuideSerie 
										AND 
										RPD.Guide_Number = @TokenGuideNumber 
										AND
										RPD.RowStatus = 1
								)
							)
						BEGIN

							INSERT INTO [DeliveryBackOffice].[dbo].[RoutePreparationDetail]
								(
									[RoutePreparationId]
									,[Guide_Serie]
									,[Guide_Number]
									,[RowStatus]
									,[TokenCreated]
									,[DateCreated]
									,[TokenUpdated]
									,[DateUpdated]
									,[IsCustomerReschedule]
								)
							OUTPUT inserted.IdRoutePreparationDetail INTO @InsertedRoutePreparationDetail (IdRoutePreparationDetail)
							VALUES 
								(
									@NewRoutePreparation
									, @TokenGuideSerie
									, @TokenGuideNumber
									, 1
									, 'SYS-HERMESROUTESLanding'
									, GETDATE()
									, NULL
									, NULL
									, 1
								)

							IF @@ROWCOUNT > 0
							BEGIN
								SET @UpdatedRP = 1
							END
		
						END

					END
					
					-- Extraer guía del manifiesto de despacho actual
					UPDATE
						DSD
					SET
						DSD.RowStatus = 0
						,DSD.TokenUpdated = 'SYS-HERMESROUTESLanding'
						,DSD.DateUpdated = GETDATE()
					FROM
						[DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] DOBS WITH(NOLOCK)
						INNER JOIN
							[DeliveryBackOffice].[dbo].[DeliverySettlementDetail] DSD WITH(NOLOCK)
							ON
								DOBS.ID = DSD.ID_DeliveryOrderBySettlement
								AND
								DSD.Guide_Serie = @TokenGuideSerie
								AND
								DSD.Guide_Number = @TokenGuideNumber
					WHERE
						DOBS.ID = @DeliverySettlementId

					-- Extraer guía de la ruta de despacho actual
					UPDATE
						RPD
					SET
						RPD.RowStatus = 0
						,RPD.TokenUpdated = 'SYS-HERMESROUTESLanding'
						,RPD.DateUpdated = GETDATE()
					FROM
						[DeliveryBackOffice].[dbo].[RoutePreparation] RP WITH(NOLOCK)
						INNER JOIN
							[DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD WITH(NOLOCK)
							ON
								RP.IdRoutePreparation = RPD.RoutePreparationId
								AND
								RPD.Guide_Serie = @TokenGuideSerie
								AND
								RPD.Guide_Number = @TokenGuideNumber
					WHERE
						RP.IdRoutePreparation = @RoutePreparationId

					-- Extraer piezas de guía de la ruta de despacho actual
					UPDATE
						RPDP
					SET
						RPDP.RowStatus = 0
						,RPDP.TokenUpdated = 'SYS-HERMESROUTESLanding'
						,RPDP.DateUpdated = GETDATE()
					FROM
						[DeliveryBackOffice].[dbo].[RoutePreparation] RP WITH(NOLOCK)
						INNER JOIN
							[DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD WITH(NOLOCK)
							ON
								RP.IdRoutePreparation = RPD.RoutePreparationId
								AND
								RPD.Guide_Serie = @TokenGuideSerie
								AND
								RPD.Guide_Number = @TokenGuideNumber
						INNER JOIN
							[DeliveryBackOffice].[dbo].[RoutePreparationDetailPiece] RPDP WITH(NOLOCK)
							ON
								RPD.IdRoutePreparationDetail = RPDP.IdRoutePreparationDetailPiece
					WHERE
						RP.IdRoutePreparation = @RoutePreparationId

				END

			END

			IF ((@UpdatedSDFG = 1 AND ISNULL(@SetIncidence, 0) = 0 AND ISNULL(@SetReschedule,0) = 0) OR (@UpdatedDA = 1 AND ISNULL(@SetIncidence, 0) = 1 AND ISNULL(@SetReschedule,0) = 0) OR ( @UpdatedDA = 1 aND ISNULL(@SetIncidence, 0) = 1 AND @UpdatedRP = 1 AND ISNULL(@SetReschedule,0) = 1) )
			BEGIN
				COMMIT TRANSACTION;
				set @jsonResult =(
									SELECT STUFF(( 
									SELECT ',{"IdResult":200,' 
									+ '"Success":"Exito ingresando datos de entrega."}' 
									FOR XML PATH(''), TYPE
									).value('.', 'varchar(max)'),1,1,'') )
				select ('[' + @jsonResult +  ']') jsonResult 
			END
			ELSE
			BEGIN
				set @jsonResult =(
									SELECT STUFF(( 
									SELECT '{{"IdResult":500,' 
									+ '"Error":"No se actualizaron los datos"}' 
									FOR XML PATH(''), TYPE
									).value('.', 'varchar(max)'),1,1,'') )
				select ('[' + @jsonResult +  ']') jsonResultError 
				ROLLBACK TRANSACTION;
			END

		END TRY
		BEGIN CATCH
			set @jsonResult =(
								SELECT STUFF(( 
								SELECT '{{"IdResult":500,' 
								+ '"Error":"'+ERROR_MESSAGE()+'"}' 
								FOR XML PATH(''), TYPE
								).value('.', 'varchar(max)'),1,1,'') )
			select ('[' + @jsonResult +  ']') jsonResultError 
			ROLLBACK TRANSACTION;
		END CATCH
	END
	ELSE IF (@IsDelivery = 1) -- Servicio es de entrega
	BEGIN
		BEGIN TRANSACTION
		BEGIN TRY
			UPDATE [dbo].[ServiceDataForGuide]
			SET 
				DateUsed = GETDATE(),
				Latitude = @Latitude,
				Longitude = @Longitude,
				ProviderModule = (SELECT [ModIdModule] FROM [CatModule] WHERE [ModName]LIKE'%Landing Delivery Page%'),
				TokenUpdated = 'SYS-HERMESROUTESLanding',
				DateUpdated = GETDATE()
			FROM [dbo].[ServiceDataForGuide] SDFG WITH (NOLOCK)
			INNER JOIN [dbo].[DeliveryOrder] DO WITH(NOLOCK)
			ON DO.Guide_Serie = SDFG.GuideSerie AND DO.Guide_Number = SDFG.GuideNumber
			WHERE SDFG.GuideToken = @GuideToken
			AND DO.StatusOrderId IN (1,2,10,11,15) -- Solicitado, Recolectado, En ruta, En Inventario, Arribó a las instalaciones, Generado

			IF @@ROWCOUNT > 0
			BEGIN
				SET @UpdatedSDFG = 1
			END
		
			-- Si se altera la dirección del servicio 
			IF(/*ISNULL(@NewProvince,'')!='' AND ISNULL(@NewTown,'')!='' AND*/ ISNULL(@NewAddress,'')!='' /*AND ISNULL(@NewTownshipID,-1)!=-1*/ )
			BEGIN
				UPDATE [dbo].[DeliveryOrder]
				SET 
					Receiver_Address = @NewAddress
					,Receiver_Zone = IIF( ISNULL(@NewZone,'')!='', @NewZone, Receiver_Zone )
				FROM [dbo].[ServiceDataForGuide] SDFG WITH(NOLOCK)
				INNER JOIN [dbo].[DeliveryOrder] DO WITH(NOLOCK)
				ON DO.Guide_Serie = SDFG.GuideSerie AND DO.Guide_Number = SDFG.GuideNumber
				WHERE SDFG.GuideToken = @GuideToken
				AND SDFG.IsDelivery = 1

				IF @@ROWCOUNT > 0
				BEGIN
					SET @UpdatedDO = 1
				END
			END

			IF (@@TRANCOUNT > 0 AND @UpdatedSDFG = 1)
			BEGIN
				COMMIT TRANSACTION;
				set @jsonResult =(
									SELECT STUFF(( 
									SELECT ',{"IdResult":200,' 
									+ '"Success":"Exito ingresando datos de entrega."}' 
									FOR XML PATH(''), TYPE
									).value('.', 'varchar(max)'),1,1,'') )
				select ('[' + @jsonResult +  ']') jsonResult 
			END
			ELSE
			BEGIN
				set @jsonResult =(
									SELECT STUFF(( 
									SELECT '{{"IdResult":500,' 
									+ '"Error":"No se actualizaron los datos"}' 
									FOR XML PATH(''), TYPE
									).value('.', 'varchar(max)'),1,1,'') )
				select ('[' + @jsonResult +  ']') jsonResultError 
				ROLLBACK TRANSACTION;
			END

		END TRY
		BEGIN CATCH
			set @jsonResult =(
								SELECT STUFF(( 
								SELECT '{{"IdResult":500,' 
								+ '"Error":"'+ERROR_MESSAGE()+'"}' 
								FOR XML PATH(''), TYPE
								).value('.', 'varchar(max)'),1,1,'') )
			select ('[' + @jsonResult +  ']') jsonResultError 
			ROLLBACK TRANSACTION;
		END CATCH
	END
	ELSE IF EXISTS (SELECT TOP 1 1 FROM ConfirmationOfIncidence coi WITH (NOLOCK) WHERE coi.ConfirmationOfIncidentToken = @GuideToken AND coi.RowStatus = 1)
	BEGIN
		
		BEGIN TRANSACTION
		
		BEGIN TRY
			IF @IsConfirmed = 1
			BEGIN
				SET @StatusOrderId = (SELECT StatusOrderId FROM StatusOrder WITH(NOLOCK) WHERE OrderDescription = 'Intento de entrega fallida')
				SET @CatTypeConfirmationOfIncidenceId = (SELECT IdCatTypeConfirmationOfIncidence FROM CatTypeConfirmationOfIncidence WHERE [Name] = 'Visita Fallida') 
			END
			ELSE
			BEGIN
				SET @StatusOrderId = (SELECT StatusOrderId FROM StatusOrder WITH(NOLOCK) WHERE OrderDescription = 'Incidencia en ruta')
				SET @CatTypeConfirmationOfIncidenceId = (SELECT IdCatTypeConfirmationOfIncidence FROM CatTypeConfirmationOfIncidence WHERE [Name] = 'Incidencia en Ruta') 
			END

			-- Si tiene diferente estado, actualizar 
			IF EXISTS (SELECT 1 FROM ConfirmationOfIncidence WITH(NOLOCK) WHERE ConfirmationOfIncidentToken = @GuideToken AND RowStatus = 1 AND StatusOrderId <> @StatusOrderId)
			BEGIN 
			
				UPDATE dod 
				SET StatusOrderId = @StatusOrderId
				FROM DeliveryOrderDetail dod
				INNER JOIN DeliveryAttempt da WITH (NOLOCK)
					ON dod.Guide_Serie = da.Guide_Serie
					AND dod.Guide_Number = da.Guide_Number
				INNER JOIN ConfirmationOfIncidence coi 
					ON da.ConfirmationOfIncidenceId = coi.IdConfirmationOfIncidence
				WHERE coi.ConfirmationOfIncidentToken = @GuideToken
				AND coi.RowStatus = 1
				AND dod.StatusOrderId = coi.StatusOrderId
				AND dod.DateCreated = coi.DateStatusOrder

				UPDATE do
				SET StatusOrderId = @StatusOrderId 
				FROM DeliveryOrder do
				INNER JOIN DeliveryAttempt da WITH (NOLOCK)
					ON do.Guide_Serie = da.Guide_Serie
					AND do.Guide_Number = da.Guide_Number
				INNER JOIN ConfirmationOfIncidence coi 
					ON da.ConfirmationOfIncidenceId = coi.IdConfirmationOfIncidence
				WHERE coi.ConfirmationOfIncidentToken = @GuideToken
				AND coi.RowStatus = 1

				UPDATE dop
				SET StatusOrderId = @StatusOrderId
				FROM DeliveryOrderPiece dop
				INNER JOIN DeliveryAttempt da WITH (NOLOCK)
					ON dop.GuideSerie = da.Guide_Serie
					AND dop.GuideNumber = da.Guide_Number
				INNER JOIN ConfirmationOfIncidence coi 
					ON da.ConfirmationOfIncidenceId = coi.IdConfirmationOfIncidence
				WHERE coi.ConfirmationOfIncidentToken = @GuideToken
				AND coi.RowStatus = 1
			

			END
		

			UPDATE ConfirmationOfIncidence
			SET IsConfirmed = 1
			   ,StatusOrderId = @StatusOrderId
			   ,CatTypeConfirmationOfIncidenceId = @CatTypeConfirmationOfIncidenceId
			   ,TokenUpdated = 'SetServiceTokenGuideData'
			   ,DateUpdated = GETDATE()
			WHERE ConfirmationOfIncidentToken = @GuideToken
			AND RowStatus = 1

			COMMIT TRANSACTION
			set @jsonResult =(
								SELECT STUFF(( 
								SELECT ',{"IdResult":200,' 
								+ '"Success":"Exito ingresando datos de incidencia."}' 
								FOR XML PATH(''), TYPE
								).value('.', 'varchar(max)'),1,1,'') )
			select ('[' + @jsonResult +  ']') jsonResult 
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION
			set @jsonResult =(
								SELECT STUFF(( 
								SELECT '{{"IdResult":500,' 
								+ '"Error":"'+ERROR_MESSAGE()+'"}' 
								FOR XML PATH(''), TYPE
								).value('.', 'varchar(max)'),1,1,'') )
			select ('[' + @jsonResult +  ']') jsonResultError 
		END CATCH
	END	
	ELSE
	BEGIN

		/* OTROS FLUJOS - POR IMPLEMENTAR */
		set @jsonResult =(
							SELECT STUFF(( 
							SELECT '{{"IdResult":500,' 
							+ '"Error":"No se actualizaron los datos"}' 
							FOR XML PATH(''), TYPE
							).value('.', 'varchar(max)'),1,1,'') )
		select ('[' + @jsonResult +  ']') jsonResultError 

	END
END