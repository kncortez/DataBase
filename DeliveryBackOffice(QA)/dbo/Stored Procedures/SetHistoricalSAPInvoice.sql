
/****** 
 **** Author: Marco, Jiménez
 **** Desc:   SP, para poder almacenar internamente la información de la factura que se envío a SAP
 **** Date:   25/09/2021
 ******/

CREATE PROCEDURE [dbo].[SetHistoricalSAPInvoice]
@inv_pk_id AS bigint,
@inv_certificationFEL AS varchar(200),
@inv_serieFEL AS varchar(200),
@inv_numberFEL AS varchar(200),
@inv_SAPDocEntry AS INT,
@inv_SAPError AS VARCHAR(MAX)
AS
BEGIN	

	BEGIN TRY
	
		INSERT INTO HistoricalSAPInvoice VALUES(
		@inv_pk_id,
		@inv_certificationFEL,
		@inv_serieFEL,
		@inv_numberFEL,
		@inv_SAPDocEntry,
		@inv_SAPError,
		GETDATE(),
		1
		)
		
		
	END TRY
	BEGIN CATCH
		SELECT 
				'FALSE'	blnResult,
				CAST(-1 AS VARCHAR(5)) IdResult,
				CAST(500 AS VARCHAR(5)) StatusResult,
				CAST(ERROR_NUMBER() AS VARCHAR) AS ErrorNumber,
				CAST(ERROR_SEVERITY() AS VARCHAR) AS ErrorSeverity,
				CAST(ERROR_STATE() AS VARCHAR) AS ErrorState,
				CAST(ERROR_PROCEDURE() AS VARCHAR) AS ErrorProcedure,
				CAST(ERROR_LINE() AS VARCHAR) AS ErrorLine,
				CAST(ERROR_MESSAGE() AS VARCHAR) AS ResultMessage;

		
	END CATCH;	
	
END
