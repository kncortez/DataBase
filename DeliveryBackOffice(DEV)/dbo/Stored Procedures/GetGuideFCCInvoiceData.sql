-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-05-23>
-- Description:	< Devuelve los datos necesarios para reimpresión de facturas >
-- =============================================

CREATE PROCEDURE [dbo].[GetGuideFCCInvoiceData] 
	@GuideNumber INT,
	@GuideSerie NVARCHAR(2) = 'FD'

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @IdCountry NVARCHAR(2)=(SELECT SenderCountryId FROM dbo.DeliveryOrder
                                                               WHERE Guide_Number = @GuideNumber);
    DECLARE @PBX NVARCHAR(10)=(SELECT [Value] FROM dbo.configparams
													WHERE [Name]='PBX' AND IdCountry='HN'
													);
	-- Variables "configurables"
	DECLARE @GoodResponseMessage NVARCHAR(MAX) = CONCAT('Estimado cliente, se le ha enviado al correo <MAIL> la factura de la guía FD', @GuideNumber, '.');
	DECLARE @BadResponseMessage NVARCHAR(300) = CONCAT('Estimado cliente, le comentamos que la guía FD', @GuideNumber, ' no tiene datos de facturación.');
	DECLARE @FailureResponseMessage NVARCHAR(300) = 'Estimado cliente, ha ocurrido un error al procesar su solicitud, por favor, intente de nuevo más tarde.';
	
	DECLARE @ResponseTable AS TABLE(
		GuideFELCertification NVARCHAR(200),
		GuideFELClientMail NVARCHAR(500),
		GuideFELVPC INT,
		IdCountry NVARCHAR(2),
		inv_pk_id INT, 
        inv_numberFEL INT,
		inv_cli_name NVARCHAR(500),
		inv_FechaHoraFEL DATETIME,
		inv_cli_nit NVARCHAR(20),
		dti_amount decimal(18,2)
	);
	
	BEGIN TRY

		INSERT INTO
			@ResponseTable
			(GuideFELCertification, GuideFELClientMail, GuideFELVPC,IdCountry, inv_pk_id, inv_numberFEL, inv_cli_name,inv_FechaHoraFEL,inv_cli_nit,dti_amount)
		SELECT
			TOP 1 
					InH.inv_certificationFEL,
					InH.inv_cli_email,
					InH.inv_vpCodeOfReferences,
					INH.IdCountry,
					inv_pk_id, 
					inv_numberFEL,
					inv_cli_name,
					inv_FechaHoraFEL,
					inv_cli_nit,
					dti_amount
				FROM 
					dbo.invoiceheader InH WITH (NOLOCK)
					INNER JOIN
						dbo.invoicedetail InD WITH (NOLOCK)
						ON 
							InH.inv_pk_id = InD.dti_fk_header
		WHERE 
			InD.dti_fk_orderNumber = @GuideNumber 
			AND 
			InH.inv_certificationFEL IS NOT NULL
			AND
			InH.inv_creditNote IS NULL

		IF( EXISTS (SELECT TOP 1 1 FROM @ResponseTable) )
		BEGIN

			SELECT
				TOP 1
					1 [blnResult]
					,REPLACE(@GoodResponseMessage,'<MAIL>',RT.GuideFELClientMail) [messageResult]
					,@FailureResponseMessage [errorMessageResult]
					,RT.GuideFELCertification
					,RT.GuideFELClientMail
					,RT.GuideFELVPC
					,ISNULL(RT.IdCountry,'GT') IdCountry
					,inv_pk_id, 
					inv_numberFEL,
					inv_cli_name,
					inv_FechaHoraFEL,
					inv_cli_nit,
					dti_amount,
					IIF(ISNULL(RT.IdCountry,'GT')='GT','Q','L') currency,
					@PBX PBX
			FROM
				@ResponseTable RT

		END
		ELSE
		BEGIN

			SELECT
				0 [blnResult] -- Indica que no existe un último estado publico posible de retornar
				,@BadResponseMessage [messageResult]

		END

	END TRY
	BEGIN CATCH
	
		SELECT
			0 [blnResult] -- Indica que no existe un último estado publico posible de retornar
			,@FailureResponseMessage [messageResult]

	END CATCH
END