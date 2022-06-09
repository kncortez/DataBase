
-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-01-03>
-- Description:	< Inserta registros en bitacora de servicios trasladados a y retornados desde una plataforma externa.>
-- =============================================
-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-03-15>
-- Description:	< Mejora para identificación de origen de ubicación prelocalizada.>
-- =============================================
CREATE PROCEDURE [dbo].[SetExternalPlatformServiceData]
	@TblSimplirouteVisits AS TblExtPlatSimplirouteVisit READONLY,
	@ExternalPlatform AS INT,
	@ServiceInputType AS INT,
	@UserToken AS NVARCHAR(50)
AS
BEGIN

	-- Manejo de origenes de ubicaciones
	DECLARE @LocationByExternalPlatform INT = 0;
	DECLARE @LocationBySMS INT = 0;
	DECLARE @LocationBySocialSecurity INT = 0;
	DECLARE @LocationByPhone INT = 0;

	IF(@ExternalPlatform = 2) -- SIMPLIROUTE
	BEGIN
		IF(@ServiceInputType = 1) -- VISITAS GENERADAS EXITOSAMENTE
		BEGIN
			BEGIN TRANSACTION
			BEGIN TRY
			

				-- Revisar por identificador de origenes
				SET @LocationByExternalPlatform = ISNULL((
					SELECT
						TOP 1
							COLR.IdCatOriginLocationRecord
					FROM
						[DeliveryBackOffice].[dbo].[CatOriginLocationRecord] COLR
					WHERE
						COLR.OriginDescription = 'Ubicación por plataforma externa' COLLATE Latin1_General_CI_AI
						AND
						COLR.RowStatus = 1
				),0)
				SET @LocationBySMS = ISNULL((
					SELECT
						TOP 1
							COLR.IdCatOriginLocationRecord
					FROM
						[DeliveryBackOffice].[dbo].[CatOriginLocationRecord] COLR
					WHERE
						COLR.OriginDescription = 'Ubicación por SMS' COLLATE Latin1_General_CI_AI
						AND
						COLR.RowStatus = 1
				),0)
				SET @LocationBySocialSecurity = ISNULL((
					SELECT
						TOP 1
							COLR.IdCatOriginLocationRecord
					FROM
						[DeliveryBackOffice].[dbo].[CatOriginLocationRecord] COLR
					WHERE
						COLR.OriginDescription = 'Ubicación por historico de número de seguridad social' COLLATE Latin1_General_CI_AI
						AND
						COLR.RowStatus = 1
				),0)
				SET @LocationByPhone = ISNULL((
					SELECT
						TOP 1
							COLR.IdCatOriginLocationRecord
					FROM
						[DeliveryBackOffice].[dbo].[CatOriginLocationRecord] COLR
					WHERE
						COLR.OriginDescription = 'Ubicación por historico de teléfono' COLLATE Latin1_General_CI_AI
						AND
						COLR.RowStatus = 1
				),0)

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
					[IsPreLocated],
					[CatOriginLocationRecordId]
				)
				OUTPUT inserted.IdExtPlatformService,inserted.IdService,inserted.Reference INTO @InsertedIDs(id,idService,reference)
				SELECT
					@ExternalPlatform,
					[IdService] ,
					CONCAT([GuideSerie],[GuideNumber]) ,
					[TrackingData] ,
					[Plan] ,
					[Route] ,
					[Order] ,
					[Address] ,
					[Latitude] ,
					[Longitude] ,
					[driver],
					[Vehicle] ,
					[observation] ,
					[IsIncluded] ,
					[IsDelivery] ,
					[ServiceStatus] ,
					[EstimatedTimeArrival] ,
					1 ,
					@UserToken ,
					GETDATE(),
					IIF([observation] IN ('2','3','4'), 1, 0),
					(
						CASE
							WHEN [observation] = '2' THEN @LocationBySMS
							WHEN [observation] = '3' THEN @LocationBySocialSecurity
							WHEN [observation] = '4' THEN @LocationByPhone
							ELSE
								@LocationByExternalPlatform
						END
					)
				FROM @TblSimplirouteVisits;	
				-- VINCULAR GUIAS CON VISITAS
				INSERT DeliveryBackOffice.dbo.[ExtPlatServiceRelationshipWithGuide](
					[ExtPlatServiceId] ,
					[GuideSerie] ,
					[GuideNumber] ,
					[RowStatus] ,
					[TokenCreated] ,
					[DateCreated]
				)
				SELECT
					IIDS.id ,
					TSV.[GuideSerie] ,
					TSV.[GuideNumber] ,
					1 ,
					@UserToken ,
					GETDATE()
				FROM @TblSimplirouteVisits TSV
				JOIN @InsertedIDs IIDS ON IIDS.idService = TSV.IdService;

				UPDATE EPSL
				SET EPSL.RowStatus = 0, EPSL.TokenUpdated = 'SYS-HERMESROUTES', EPSL.DateUpdated = GETDATE()
				FROM [DeliveryBackOffice].[dbo].[ExternalPlatformServiceLog] EPSL
				JOIN @TblSimplirouteVisits TSV
				ON EPSL.GuideSerie = TSV.GuideSerie
				AND EPSL.GuideNumber = TSV.GuideNumber

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
		ELSE IF (@ServiceInputType = 2) -- VISITAS CON FALLAS (DIRECCION NO COMPRENSIBLE, NO ATENDIDAD O FILTARDAS FUERA DE RUTA)
		BEGIN
			BEGIN TRANSACTION
			BEGIN TRY
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
					@ExternalPlatform,
					0 ,
					CONCAT([GuideSerie],[GuideNumber]) ,
					[Plan] ,
					[Address] ,
					[Latitude] ,
					[Longitude] ,
					[observation] ,
					[IsIncluded] ,
					[IsDelivery] ,
					'notIncluded' ,
					1 ,
					@UserToken ,
					GETDATE()
				FROM @TblSimplirouteVisits ;	
				-- VINCULAR GUIAS CON VISITAS
				INSERT DeliveryBackOffice.dbo.[ExtPlatServiceRelationshipWithGuide](
					[ExtPlatServiceId] ,
					[GuideSerie] ,
					[GuideNumber] ,
					[RowStatus] ,
					[TokenCreated] ,
					[DateCreated]
				)
				SELECT
					IIDS2.id ,
					IIDS2.GuideSerie ,
					IIDS2.GuideNumber ,
					1 ,
					@UserToken ,
					GETDATE()
				FROM @InsertedIDs2 IIDS2;

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
	END
END
