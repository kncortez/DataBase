-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date, 2023-04-28>
-- Description:	<Description, Método para registro de ubicación de Courier>
-- =============================================
CREATE PROCEDURE [dbo].[CouriermanLocationRecord] 
	@CourierIdentifier   AS INT,
    @CourierLatitude AS VARCHAR,
    @CourierLength AS VARCHAR,
    @LocationAccuracy  AS VARCHAR
AS
BEGIN   
	

	BEGIN TRANSACTION
	BEGIN TRY

			INSERT INTO [dbo].[SenderReceiverLocationLog]
			(
			 SenderReceiverId,
			 CourierLatitude,
			 CourierLongitude,
			 LocationAccuracy,
			 LocationDate,
			 LocationTime,
			 RowStatus,
			 DateCreated,
			 TokenCreated
	
			 )
			 Values
			 (
			 @CourierIdentifier,
			 @CourierLatitude,
			 @CourierLength,
			 @LocationAccuracy,
			 CONVERT (date, GETDATE()),
			 CONVERT(VARCHAR, getdate(), 108),
			 1,
			 GETDATE(),
			 'Courierman Location Record'
			 )

			 SELECT 1 AS 'Result' 

	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH

	ROLLBACK TRANSACTION

		 SELECT 1 AS 'Result' 

    END CATCH




END