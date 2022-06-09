
/****** 
 **** Author: Marco, Jiménez
 **** Desc:   SP, para poder validar si una factura ya fue enviada a SAP
 **** Date:   25/09/2021
 ******/

CREATE PROCEDURE [dbo].[GetHistoricalSAPInvoiceValidation]
@inv_certificationFEL AS NVARCHAR(200)
AS
BEGIN	
DECLARE @RESULT VARCHAR(10) = 'FALSE'

	SET @RESULT = (SELECT 'TRUE' FROM HistoricalSAPInvoice 
	WHERE inv_certificationFEL = @inv_certificationFEL 
	)

	IF(ISNULL(@RESULT,'FALSE') = 'FALSE')
	BEGIN
	SET @RESULT = 'FALSE'
	END

	SELECT @RESULT AS 'Result'
	
END
