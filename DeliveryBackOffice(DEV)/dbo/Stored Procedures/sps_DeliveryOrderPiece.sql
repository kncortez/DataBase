
-- =============================================
-- Author:		<???,???>
-- Create date: <????-??-??>
-- Description:	< Inserción de pieza de guía >
-- =============================================
-- =============================================
-- Author:		<Andres,Ruiz>
-- Update date: <2022-02-28>
-- Description:	< Actualización de peso de guía al ingresar dato de pieza >
-- =============================================
CREATE PROCEDURE [dbo].[sps_DeliveryOrderPiece] 
   @GuideSerie			varchar(2) = 'FD'  
  ,@GuideNumber			int = 138014
  ,@PiecePhysicalWeight	decimal(12,2) = 0
  ,@PieceHeight			decimal(12,2) = 0 
  ,@PieceWidth			decimal(12,2) = 0
  ,@PieceLength			decimal(12,2) = 0
  ,@PieceWeight			decimal(12,2) = 0
  ,@DateCreated			datetime
  ,@fragile				bit = 0 
  ,@Detail				varchar(2500) = ''
  ,@Currency			varchar(15) = ''
  ,@Amount				decimal(12,2) = 0
  ,@PieceNumber         int
  ,@VolumetricWeight	decimal (12,2)
  ,@CodeOfSeller		varchar(20) =''
  ,@ParcelCode			varchar(20) =''
AS 
BEGIN

	DECLARE @ResponseIdentity NUMERIC(18,0) = 0;
	DECLARE @EXCCustomerId INT = 0;
	DECLARE @IsClientEXC BIT = 0;
    DECLARE @IdCountry NVARCHAR(2) = 'GT';

    SET @IdCountry = (
                      SELECT TOP 1 
                             SenderCountryId
                        FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
                       WHERE DO.Guide_Serie = @GuideSerie
                         AND DO.Guide_Number = @GuideNumber
                     )

	-- Buscar customer que representa Express Centers
	SET @EXCCustomerId = (
		SELECT
			TOP 1
				[KoVPC].[IdKindOfVPClient]
		FROM
			[DeliveryBackOffice].[dbo].[KindOfVPClient] KoVPC  WITH(NOLOCK) 
		WHERE
			[KoVPC].[KindOfVPName] = 'Express Center'  COLLATE Latin1_General_CI_AI 
          AND ISNULL(IdCountry,'GT') = @IdCountry
	)

	-- Si la guía se origino en Express Center
	SET @IsClientEXC = (
		SELECT 
			TOP 1
				1
		FROM
			[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[VisitPointClient] VPCSend WITH(NOLOCK)
				ON
					DO.Sender_ID = [VPCSend].CodeOfReference
					AND
					[VPCSend].StatusClient = 1
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[VisitPointClient] VPCOri  WITH(NOLOCK) 
				ON
					DO.[OriginSenderId] = [VPCOri].[CodeOfReference]
					AND
					[VPCOri].[StatusClient] = 1
		WHERE
			DO.Guide_Serie = @GuideSerie
			AND
			DO.Guide_Number = @GuideNumber
			AND
			(
				(
					[VPCSend].[IdKindOfVPClient] = @EXCCustomerId
					AND
					[VPCSend].[IdVisitPointClient] IS NOT NULL
				)
				OR
				(
					[VPCOri].[IdKindOfVPClient] = @EXCCustomerId
					AND
					[VPCOri].[IdVisitPointClient] IS NOT NULL
				)
			)
	)

	BEGIN TRANSACTION
	BEGIN TRY

		INSERT INTO DeliveryBackOffice.[dbo].[DeliveryOrderPiece] (
			GuideSerie
			,GuideNumber
			,PiecePhysicalWeight
			,PieceHeight
			,PieceWidth
			,PieceLength
			,PieceWeight
			,DateCreated
			,fragile
			,Detail
			,Currency
			,Amount
			,NoPiece
			,CodeOfSeller
			,ParcelCode
		)
		VALUES (
			@GuideSerie			
			,@GuideNumber			
			,@VolumetricWeight	
			,@PieceHeight			
			,@PieceWidth			
			,@PieceLength			
			,@PieceWeight			
			,@DateCreated			
			,@fragile
			,@Detail
			,@Currency
			,@Amount
			,@PieceNumber
			,@CodeOfSeller
			,@ParcelCode
		)

		-- Guardar registro reciente de pieza
		SET @ResponseIdentity = @@IDENTITY

		IF(@IsClientEXC = 1)
		BEGIN
			-- Recalcular peso de guía
			DECLARE @GuideWeightReview AS TABLE (
				GuideSerie NVARCHAR(2),
				GuideNumber INT,
				GuideWeight DECIMAL(12,2)
			)

			-- Peso de guía de express center
			INSERT INTO @GuideWeightReview
				(GuideSerie, GuideNumber, GuideWeight)
			SELECT
				DO.Guide_Serie
				,DO.Guide_Number
				,SUM
				(
					CASE -- Datos dados por el cliente se generan en estos campos: PieceWeight y PiecePhysicalWeight (Peso volumetrico)
						WHEN DOP.[PieceWeight] IS NOT NULL AND DOP.[PiecePhysicalWeight] IS NULL THEN DOP.[PieceWeight]
						WHEN DOP.[PieceWeight] IS NULL AND DOP.[PiecePhysicalWeight] IS NOT NULL THEN DOP.[PiecePhysicalWeight]
						WHEN DOP.[PieceWeight] IS NULL AND DOP.[PiecePhysicalWeight] IS NULL THEN 0 
						WHEN DOP.[PieceWeight] > DOP.[PiecePhysicalWeight] THEN DOP.[PieceWeight]
						WHEN DOP.[PieceWeight] < DOP.[PiecePhysicalWeight] THEN DOP.[PiecePhysicalWeight]
						WHEN DOP.[PieceWeight] = DOP.[PiecePhysicalWeight] THEN DOP.[PiecePhysicalWeight]
					END
				) 'Weight'
			FROM
				[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOP WITH(NOLOCK)
					ON
						DO.Guide_Serie = DOP.GuideSerie
						AND
						DO.Guide_Number = DOP.GuideNumber
			WHERE
				DO.Guide_Serie = @GuideSerie
				AND
				DO.Guide_Number = @GuideNumber 
			GROUP BY
				DO.Guide_Serie
				,DO.Guide_Number

			-- Actualización de peso facturado
			UPDATE
				DO
			SET
				DO.BilledWeight = GWS.GuideWeight
			FROM
				[DeliveryBackOffice].[dbo].[DeliveryOrder] DO  WITH(NOLOCK) 
				INNER JOIN 
					@GuideWeightReview GWS
					ON
						DO.Guide_Serie = GWS.GuideSerie
						AND
						DO.Guide_Number = GWS.GuideNumber
			WHERE
				DO.Guide_Serie = @GuideSerie
				AND
				DO.Guide_Number = @GuideNumber 
		END

		IF(@@TRANCOUNT > 0)
			COMMIT TRANSACTION

		SELECT @ResponseIdentity
	END TRY
	BEGIN CATCH
		SELECT 
			0 [blnResult],
			ERROR_NUMBER() AS [ErrorNumber],
			ERROR_SEVERITY() AS [ErrorSeverity],
			ERROR_STATE() AS [ErrorState],
			ERROR_PROCEDURE() AS [ErrorProcedure],
			ERROR_LINE() AS [ErrorLine],
			ERROR_MESSAGE() AS [ErrorMessage];

		ROLLBACK TRANSACTION
	END CATCH
END