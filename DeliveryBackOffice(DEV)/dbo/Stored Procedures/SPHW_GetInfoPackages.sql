-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2024-10-10>
-- Description:	<Delivery Tracking - Obtener información de los paquetes, cantidad y precio total para pago de la guía.>
-- =============================================

CREATE PROCEDURE [dbo].[SPHW_GetInfoPackages]
@GuideSerie NVARCHAR(4),
@GuideNumber INT
AS
BEGIN
BEGIN TRY
	
	DECLARE @StatusIncVal INT  = (
		SELECT StatusOrderId FROM DeliveryBackOffice.dbo.StatusOrder
		WHERE OrderDescription = 'Incidencia Validada'
	)

    DECLARE @f1 NVARCHAR(10) = (
		SELECT
			CASE
				WHEN 
					IsLastMileReturn = 1 OR
					(SELECT COUNT(CI.IdConfirmationOfIncidence) FROM DeliveryBackOffice.dbo.DeliveryAttempt DA WITH(NOLOCK)
					 INNER JOIN DeliveryBackOffice.dbo.ConfirmationOfIncidence CI WITH(NOLOCK)
						ON DA.ConfirmationOfIncidenceId = CI.IdConfirmationOfIncidence
					 WHERE DA.Guide_Serie = @GuideSerie AND DA.Guide_Number = @GuideNumber 
						AND CI.StatusOrderId = @StatusIncVal AND CI.IsConfirmed = 1 AND CI.IsDenied = 0) > 1 --INTENTO DEVOLUCIONES
				THEN 'false'
				ELSE 'true'
			END AS 'flagRescheduleDelivery'
		FROM DeliveryBackOffice.dbo.DeliveryOrder WITH(NOLOCK)
		WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber
	);


	IF(@f1 = 'true')
	BEGIN

		SELECT
				200						 AS 'IdResult'
			, 'Exitoso.'				 AS 'Message'
			, DOP.ParcelCode			 AS 'Code'
			, DOP.Detail				 AS 'Detail'
			, 'Max: ' + CAST(FLOOR(DOP.PieceHeight) AS NVARCHAR(10))
			+ 'cm o ' + CAST(FLOOR(DOP.PieceWeight) AS NVARCHAR(10)) + 'lbs'		AS 'Description'
			, COUNT(DOP.ParcelCode)		 AS 'Quantity'
			, DO.PriceShippment			 AS 'Amount'
			, ISNULL(CCC.Symbol,'Q')	 AS 'CurrencySymbol'
		FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH(NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece DOP WITH(NOLOCK)
			ON DO.Guide_Serie = DOP.GuideSerie AND DO.Guide_Number = DOP.GuideNumber
		LEFT JOIN DeliveryBackOffice.dbo.Cost C WITH(NOLOCK)
			ON DO.Guide_Serie = C.GuideSerie AND DO.Guide_Number = C.GuideNumber
		LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD CCC WITH(NOLOCK)
			ON ISNULL(C.ShippingCurrency,C.CodCurrency) = CCC.IdCatCurrencyCOD
		WHERE DO.Guide_Serie = @GuideSerie AND DO.Guide_Number = @GuideNumber
		GROUP BY DOP.ParcelCode, DOP.Detail, DOP.PieceHeight,  DOP.PieceWeight, DO.PriceShippment, CCC.Symbol

	END;
	ELSE
	BEGIN
		SELECT 
				401											AS 'IdResult'
			, 'No es posible ingresar al pago de envío.'	AS 'Message'
	END;

END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
END;