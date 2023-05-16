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
	@status INT,
	@FiscalName NVARCHAR(100),
	@InvoiceDate NVARCHAR(100)
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
			   inv_status = @status,
			   inv_cmp_nameFEL = @FiscalName,
			   inv_FechaHoraFEL = @InvoiceDate,
			   inv_cmp_name = 'DELIVERY EXPRESS, SOCIEDAD ANONIMA',
			   inv_cmp_nameComercial = 'DELIVERY EXPRESS'
			   ,inv_cmp_adress = 'AVENIDA PETAPA 42-51   ZONA 12 EDIFICIO C,'
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