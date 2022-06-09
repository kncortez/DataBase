
-- =============================================
-- Author:		<Andres,Ruiz>
-- Update date: <2022-02-28>
-- Description:	< Actualización de peso de guía al ingresar dato de pieza >
-- =============================================
CREATE PROCEDURE [dbo].[UpdateDeliveryOrderTotalWeight] 
   @GuideSerie			NVARCHAR(2) = 'FD'  
  ,@GuideNumber			INT = 138014
AS 
BEGIN

	BEGIN TRANSACTION
	BEGIN TRY

		-- Recalcular peso de guía
		DECLARE @GuideWeightReview AS TABLE (
			GuideSerie NVARCHAR(2),
			GuideNumber INT,
			GuideWeight DECIMAL(12,2)
		)

		-- Peso de guía recalculado
		INSERT INTO @GuideWeightReview
			(GuideSerie, GuideNumber, GuideWeight)
		SELECT
			DO.Guide_Serie
			,DO.Guide_Number
			,SUM
			(
				CASE 
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
			[DeliveryBackOffice].[dbo].[DeliveryOrder] DO
			LEFT JOIN 
				@GuideWeightReview GWS
				ON
					DO.Guide_Serie = GWS.GuideSerie
					AND
					DO.Guide_Number = GWS.GuideNumber
		WHERE
			DO.Guide_Serie = @GuideSerie
			AND
			DO.Guide_Number = @GuideNumber 

		IF(@@TRANCOUNT > 0)
			COMMIT TRANSACTION

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
