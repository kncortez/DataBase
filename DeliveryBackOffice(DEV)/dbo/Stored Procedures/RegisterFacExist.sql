-- =============================================
-- Author:		<Eduardo, López>
-- Create date: <2022-09-13>
-- Description:	<Revisar si guía no tiene registros incompletos en invoiceHeader e invoiceDetail>
-- =============================================

CREATE PROCEDURE [dbo].[RegisterFacExist]
    @serie varchar(5),
	@guide int

AS
BEGIN
	DECLARE @invoiceHeaderId bigint=-1;

	SET @invoiceHeaderId =(SELECT TOP 1 ivhd.inv_pk_id
				 FROM invoiceDetail ind
				 INNER JOIN invoiceHeader ivhd
				 ON ind.dti_fk_header = ivhd.inv_pk_id
				 WHERE ind.dti_fk_orderSerie = @serie
				 AND ind.dti_fk_orderNumber = @guide
				 AND ivhd.inv_certificationFEL IS NULL
				);

	IF(@invoiceHeaderId IS NULL)
		BEGIN
			SET @invoiceHeaderId = 0;
			SELECT @invoiceHeaderId 'IDENTITY'
		END
	ELSE
	    BEGIN
			SELECT @invoiceHeaderId 'IDENTITY'
		END
	
END