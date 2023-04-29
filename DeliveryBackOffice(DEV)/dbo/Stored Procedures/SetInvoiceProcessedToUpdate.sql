-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2023-04-28>
-- Description:	<Guarda información de facturas que ya se han procesado>
-- =============================================
CREATE PROCEDURE [dbo].[SetInvoiceProcessedToUpdate]
	@id bigint,
	@certificationFEL varchar(200),
	@serieFEL varchar(200),
	@numberFEL varchar(50),
	@descriptionFEL varchar(500),
	@status int
AS
BEGIN
	BEGIN TRY

			UPDATE DeliveryBackOffice.dbo.invoiceHeader
			SET inv_certificationFEL = @certificationFEL
			   ,inv_serieFEL = @serieFEL
			   ,inv_numberFEL = @numberFEL
			   ,inv_descriptionFEL = @descriptionFEL
			   ,inv_dateUpdate = GETDATE()
			   ,inv_dateFEL = GETDATE(),
			   inv_status = @status
			WHERE inv_pk_id = @id

			SELECT
			'1' 'StatusCode'
		   ,'Datos almacenados correctamente.' 'Description'
	END TRY
	BEGIN CATCH
		
		SELECT
			'-1' 'StatusCode'
		   ,ERROR_MESSAGE() 'Description'
	END CATCH
END