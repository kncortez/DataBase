-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2024-10-10>
-- Description:	<Delivery Tracking - Obtener información de los paquetes, cantidad y precio total para pago de la guía.>
-- =============================================

CREATE PROCEDURE [dbo].[SPHW_GetInfoPackages]
@GuideSerie NVARCHAR(4),
@GuideNumber INT,
@Phone NVARCHAR(200)
AS
BEGIN
BEGIN TRY

	DECLARE @Receiver_Phone NVARCHAR(200) = (SELECT RIGHT(LTRIM(RTRIM(Receiver_Phone)), 8) FROM DeliveryBackOffice.dbo.DeliveryOrder WITH(NOLOCK)
											 WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber)

    DECLARE @CountryId NVARCHAR(3) = (SELECT ISNULL(ReceiverCountryId,'GT') FROM DeliveryBackOffice.dbo.DeliveryOrder WITH(NOLOCK)
											 WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber)

	DECLARE @CodeArea NVARCHAR(5) = (SELECT [Value] FROM DeliveryBackOffice.dbo.ConfigParams WITH(NOLOCK)
											WHERE [Name] = 'AreaCode' AND IdCountry = @CountryId)
	
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

	--Validación del telefono
	IF((@Phone = @Receiver_Phone) OR (@Phone = @CodeArea + @Receiver_Phone) OR (@Phone = '+' + @CodeArea + @Receiver_Phone))
	BEGIN
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
			FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH(NOLOCK)
			INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece DOP WITH(NOLOCK)
				ON DO.Guide_Serie = DOP.GuideSerie AND DO.Guide_Number = DOP.GuideNumber
			WHERE DO.Guide_Serie = @GuideSerie AND DO.Guide_Number = @GuideNumber
			GROUP BY DOP.ParcelCode, DOP.Detail, DOP.PieceHeight,  DOP.PieceWeight, DO.PriceShippment

		END;
		ELSE
		BEGIN
			SELECT 
				  401											AS 'IdResult'
				, 'No es posible ingresar al pago de envío.'	AS 'Message'
		END;
	END
	ELSE
	BEGIN
		SELECT 
			  409 AS 'IdResult'
			, 'El número ingresado no coincide con el registrado para este envío.' AS 'Message'
	END

END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
END;