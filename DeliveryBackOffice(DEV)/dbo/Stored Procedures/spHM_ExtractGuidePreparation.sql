-- =============================================
-- Author:		<Alberto, Ixchop>
-- Create date: <09-09-2022>
-- Description:	<Extrae una guía de una preparación de ruta vigente>
-- =============================================
-- Author:		<Jerson Ochoa>
-- Create date: <09-09-2022>
-- Description:	<Agregar nueva lógica para reversar estado de guía>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_ExtractGuidePreparation]
	-- Add the parameters for the stored procedure here
	@GuideSerie AS NVARCHAR(2),
	@GuideNumber AS INT,
	@RouteId INT = NULL,
	@DatePreparation DATE = NULL,
	@RoutePreparationId INT = NULL,
	@Token AS NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;



	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.	
	DECLARE @RecordExist BIT=0;
	DECLARE @BelongsToRoute bit=0;
	DECLARE @Msg_error NVARCHAR(100)='';
	DECLARE @current_BatchCODId INT = NULL;
    DECLARE @current_BatchCODIdCommission INT = NULL;
    DECLARE @dateBatchCOD DATE;
	DECLARE @LastState AS INT;

	--DECLARE @RecordExist BIT=0;
	IF NOT ((@DatePreparation IS NOT NULL) AND (@RouteId IS NOT NULL)) AND @RoutePreparationId IS NULL
	BEGIN 
			SELECT
				0 'StatusCode'
			   ,'Parámetros inválidos' 'Description'
	END
	ELSE IF @RoutePreparationId IS NOT NULL
	BEGIN 
		--Verificando registros existentes para parámetro routeid
		SET @RecordExist= (SELECT TOP 1 1 FROM RoutePreparation RP WHERE RP.IdRoutePreparation=@RoutePreparationId);
		--Verificando SI LA GUÍA PERTENECE AL ROUTEPREPARATION
		SELECT TOP 1 @BelongsToRoute=1 FROM DBO.RoutePreparation RP 
			INNER JOIN DBO.RoutePreparationDetail RPD ON RPD.RoutePreparationId=RP.IdRoutePreparation
		WHERE RP.IdRoutePreparation =@RoutePreparationId
		AND RPD.Guide_Serie=@GuideSerie AND RPD.Guide_Number=@GuideNumber;
		set @Msg_error='La guía no se encuentra asociada a la preparación indicada'
						
		
	END
	ELSE
	BEGIN 
		--Verificando registros existentes para parámetros @RouteId y @Datepreparation
		SET @RecordExist= (SELECT TOP 1 1 FROM RoutePreparation WHERE CatRouteId = @RouteId AND DateRoutePreparation = @DatePreparation);
		--Verificando SI LA GUÍA PERTENECE AL ROUTEPREPARATION
		SELECT TOP 1 @BelongsToRoute=1,@RoutePreparationId = RP.IdRoutePreparation FROM DBO.RoutePreparation RP 
			INNER JOIN DBO.RoutePreparationDetail RPD ON RPD.RoutePreparationId=RP.IdRoutePreparation
		WHERE RP.DateRoutePreparation =@DatePreparation and RP.CatRouteId=@RouteId
		AND RPD.Guide_Serie=@GuideSerie AND RPD.Guide_Number=@GuideNumber;
		set @Msg_error='La guía no se encuentra asociada a la ruta y la fecha indicada'
	END
	

	IF @BelongsToRoute <> 1
	BEGIN 
		SELECT
			0 'StatusCode'
			,@Msg_error 'Description'
	END
	ELSE IF @RecordExist = 0 
	BEGIN
		SELECT
			0 'StatusCode'
			,'No se encontraron guías' 'Description'
	END
	ELSE
	IF @RecordExist <> 0
	BEGIN
	BEGIN TRANSACTION
	BEGIN TRY
		--Anulando preparación de guías
		DECLARE @DRYPIECES INT =0;
		DECLARE @COLDPIECES INT =0;
		SELECT
			@DRYPIECES=COUNT(CASE WHEN RPDP.PieceType=1 THEN RPDP.IdRoutePreparationDetailPiece ELSE NULL END),
			@COLDPIECES=COUNT(CASE WHEN RPDP.PieceType=0 THEN RPDP.IdRoutePreparationDetailPiece ELSE NULL END)
		FROM DBO.RoutePreparationDetail RPD
		INNER JOIN DBO.RoutePreparationDetailPiece RPDP
			ON RPDP.RoutePreparationDetailId=RPD.IdRoutePreparationDetail	
			AND RPDP.RowStatus=1
		WHERE Guide_Number=@GuideNumber
		AND Guide_Serie=@GuideSerie
		AND RPD.RoutePreparationId=@RoutePreparationId
		AND RPDP.RowStatus=1;
		UPDATE RoutePreparation SET
			PiecesDry=PiecesDry-@DRYPIECES,
			PiecesCold=PiecesCold-@COLDPIECES
		WHERE IdRoutePreparation=@RoutePreparationId;

		UPDATE RPDP
		SET     
			TokenUpdated=@Token,
			DateUpdated= GETDATE(),
			RowStatus = 0
		FROM [DeliveryBackOffice].[dbo].[RoutePreparationDetailPiece] RPDP 
		INNER JOIN[DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD ON RPDP.RoutePreparationDetailId=RPD.IdRoutePreparationDetail
		INNER JOIN [DeliveryBackOffice].[dbo].[RoutePreparation] RP
			ON RP.IdRoutePreparation=RPD.RoutePreparationId
		WHERE RP.IdRoutePreparation=@RoutePreparationId
				AND RPD.Guide_Serie=@GuideSerie
				AND RPD.Guide_Number=@GuideNumber;;

		UPDATE RPD
		SET     
			UserProcess = NULL,
			IsOpenProcess = 0,
			RowStatus = 0,
			TokenUpdated=@Token,
			DateUpdated= GETDATE()
		FROM [DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD
		INNER JOIN [DeliveryBackOffice].[dbo].[RoutePreparation] RP
			ON RP.IdRoutePreparation=RPD.RoutePreparationId
		WHERE RP.IdRoutePreparation=@RoutePreparationId
				AND RPD.Guide_Serie=@GuideSerie
				AND RPD.Guide_Number=@GuideNumber;

		--Ejecutando sp que reversa el estádo de la guía
		--EXEC [dbo].[sphd_setReversal] @GuideSerie,@GuideNumber, 'Reversando guía por motivo de extacción de guía de una preparación de rutas de entrega en hermes móvil',@Token
		
		IF EXISTS (SELECT [PGC].[BatchCODId] FROM [dbo].[ProcessedGuideCOD] PGC WHERE [PGC].[GuideSerie] = @GuideSerie AND [PGC].[GuideNumber] = @GuideNumber AND [PGC].[RowStatus] = 1)
			BEGIN
				--Al estar en estado COD Pagado o COD Liquidado no debe permitir la reversión
				SELECT 
					@current_BatchCODId  = ISNULL(PGD.BatchCODId,BDC.BatchCODId), 
					@current_BatchCODIdCommission = ISNULL(PGD.BatchCODIdCommission,BDCCM.BatchCODId),
					@dateBatchCOD = Date
				FROM 
					DeliveryBackOffice.dbo.ProcessedGuideCOD PGD WITH (NOLOCK)
					LEFT JOIN DeliveryBackOffice.dbo.BatchDetailCOD BDC WITH (NOLOCK) 		
					ON BDC.GuideSerie = PGD.GuideSerie
					AND BDC.GuideNumber = PGD.GuideNumber
					AND BDC.CatConceptCODId = 2
					LEFT JOIN DeliveryBackOffice.dbo.BatchDetailCOD BDCCM WITH (NOLOCK)
					ON BDCCM.GuideSerie = PGD.GuideSerie
					AND BDCCM.GuideNumber = PGD.GuideNumber
					AND BDCCM.CatConceptCODId = 1
				WHERE 
					PGD.GuideSerie = @GuideSerie
					AND PGD.GuideNumber = @GuideNumber
			END

		IF (@current_BatchCODId IS NULL AND @current_BatchCODIdCommission IS NULL OR @current_BatchCODId  ='' AND @current_BatchCODIdCommission ='') --Se hace la reversión si ambos valores son NULL
			BEGIN		
						--Regresar a estado anterior en tabla DeliveryOrder
						DECLARE @currentState TINYINT,
								@NewState TINYINT;
						
						SELECT 
							@currentState = StatusOrderId
						FROM 
							DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
						WHERE 
							Guide_Serie =  @GuideSerie
							AND Guide_Number = @GuideNumber;

						----- Obtener último estado de la guía

						IF EXISTS(	SELECT * FROM [dbo].[DeliveryOrderDetail] DOD WITH (NOLOCK) 
									WHERE [DOD].[Guide_Serie] = @GuideSerie AND [DOD].[Guide_Number] = @GuideNumber AND [DOD].[RowStatus] = 1 AND [DOD].[StatusOrderId] <> @currentState)
							BEGIN
								SELECT
									   TOP 1   @LastState = StatusOrderId 
								FROM [dbo].[DeliveryOrderDetail] WITH (NOLOCK)
								WHERE   Guide_Serie = @GuideSerie AND  Guide_Number = @GuideNumber
										AND RowStatus = 1 AND StatusOrderId<> @currentState
								ORDER BY DateCreated DESC;

							   -- Se deberá actualizar al estado anterior en DeliveryOrder, según registros de DeliveryOrderDetail.
								UPDATE 
									DeliveryBackOffice.dbo.DeliveryOrder 
								SET 
									StatusOrderId = @LastState
								WHERE 
									Guide_Serie =  @GuideSerie
									AND Guide_Number = @GuideNumber
			
								--Actualizamos el registro en la tabla DeliveryOrderDetail
			
								UPDATE 
									DeliveryBackOffice.dbo.DeliveryOrderDetail ---Se deberá inactivar estado actual
								SET 
									RowStatus = 0,
									Observations = 'Guía revertida desde modulo de reversión de estados.'
				
								WHERE 
									Guide_Serie =  @GuideSerie
									AND Guide_Number = @GuideNumber
									AND StatusOrderId = @currentState
			
								--FDD-699: Revertimos guía en tabla DeliverySettlementDetail, para evitar que se liquide una guía que fue reversada
								UPDATE
									 DeliveryBackOffice.dbo.DeliverySettlementDetail
								SET
									 Guide_Returned  = 1 , 
									 Guide_Delivered = 0 
								WHERE 
									 Guide_Serie =  @GuideSerie
									 AND Guide_Number = @GuideNumber

								--Revertimos guía en tabla ProcessedGuideCOD
								--Al estar en estado Entregado deberá inactivar el registro en la ProcessedGuide, siempre y cuando el BatchID y BatchCommision sean NULL
								IF (@currentState in( 5,22))
									BEGIN
										UPDATE
											DeliveryBackOffice.dbo.ProcessedGuideCOD 
										SET
											RowStatus = 0 
										WHERE
											GuideSerie = @GuideSerie 
											AND GuideNumber = @GuideNumber
											AND BatchCODId IS NULL
											AND BatchCODIdCommission IS NULL
					   
										-------------------WEBHOOK.INI------------------------------
										UPDATE
											[DeliveryBackOffice].[dbo].[WebhookTrackingQueue]
										SET
											RowStatus = 0
											,TokenUpdated = @Token
											,DateUpdated = GETDATE()
										WHERE
											GuideSerie = @GuideSerie
											AND
											GuideNumber = @GuideNumber
											AND
											RowStatus = 1
											AND
											StatusOrderId = @currentState;
										-------------------WEBHOOK.FIN------------------------------
									END 
						
								--Por ultimo se inserta en la tabla DeliveryOrderReversalStatus para tener un log de las reversiones.
						
								INSERT INTO [dbo].[DeliveryOrderReversalStatus]
									([Guide_Serie]
									,[Guide_Number]
									,[Comment]
									,[RowStatus]
									,[TokenCreated]
									,[DateCreated])
								VALUES
									(@GuideSerie
									,@GuideNumber
									,'Reversando guía por motivo de extacción de guía de una preparación de rutas de entrega en hermes móvil'
									,1
									,@Token
									,GETDATE())
							END

			END
			SELECT 1 'StatusCode' ,'Extracción de guía correcta' 'Description';
			COMMIT TRANSACTION;
    END TRY
	BEGIN CATCH
		SELECT 0 [spResult],
				ERROR_NUMBER() AS [ErrorNumber],
				ERROR_SEVERITY() AS [ErrorSeverity],
				ERROR_STATE() AS [ErrorState],
				ERROR_PROCEDURE() AS [ErrorProcedure],
				ERROR_LINE() AS [ErrorLine],
				ERROR_MESSAGE() AS [spMessage];

		ROLLBACK TRANSACTION
	END CATCH
	END
END