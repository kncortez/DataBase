-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-10-05>
-- Description:	<Devuelve toda la información de un courier basado en su identificador en el sistema>
-- =============================================
CREATE PROCEDURE [dbo].[GetCourierDataByID]
	-- Add the parameters for the stored procedure here
	@IdCourier INT
AS
BEGIN

	DECLARE @CourierDataTable AS TABLE (
		CourierID INT,
		CourierName NVARCHAR(500),
		CourierCUI NVARCHAR(500),
		CourierPhones NVARCHAR(500)
	);

	BEGIN TRY

		INSERT INTO @CourierDataTable
			(CourierID, CourierName, CourierCUI, CourierPhones)
		SELECT 
			TOP 1
				 SR.[ID]
				,LTRIM(RTRIM(CONCAT(SR.[First_Name], ' ',SR.[Last_Name])))
				,SR.[CUI]
				,SR.[Phone]
		FROM 
			[DeliveryBackOffice].[dbo].[SenderReceiver] SR WITH(NOLOCK)
		WHERE 
			SR.ID = @IdCourier
			AND 
			SR.Entity_Type = 3

		IF(EXISTS(SELECT TOP 1 1 FROM @CourierDataTable))
		BEGIN
		
			SELECT
				200 [ResponseCode],
				'Información recuperada exitosamente.' [ResponseMessage]

			SELECT
				CDT.CourierID,
				CDT.CourierCUI,
				CDT.CourierName,
				CDT.CourierPhones
			FROM
				@CourierDataTable CDT

		END
		ELSE
		BEGIN

			SELECT
				400 [ResponseCode],
				'No se pudo recuperar información.' [ResponseMessage]
			
		END

	END TRY
	BEGIN CATCH

		SELECT
			500 [ResponseCode],
			'Error en el sistema.' [ResponseMessage]
			
	END CATCH
END