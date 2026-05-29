
-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-05-20>
-- Description:	< Devuelve script en lenguaje natural del detalle de CoD de una guía >
-- =============================================
CREATE PROCEDURE [dbo].[GetGuideFCCCoDTracking] 
	@GuideNumber INT,
	@GuideSerie NVARCHAR(2) = 'FD'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	 DECLARE @IdCountry NVARCHAR(2)=(SELECT SenderCountryId FROM dbo.DeliveryOrder with (nolock)
                                                           WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber);
	DECLARE @PHONE NVARCHAR(25);   
	DECLARE @SoportMail NVARCHAR(50);
	
    SELECT  @PHONE = [Value]
	            FROM dbo.configparams
						  WHERE  [Name]='VoucherPhone'
						  AND  IdCountry=@IdCountry 
	SELECT  
           @SoportMail = [Value]	
	                      FROM dbo.configparams
						  WHERE  [Name]='SupportEmailByCountry'
						   AND  IdCountry=@IdCountry
					

	-- Variables "configurables"
	DECLARE @GoodResponseMessage NVARCHAR(300) = CONCAT('Estimado cliente, se le enviará un reporte al correo <MAIL> basado en la guía FD', @GuideNumber, '');
	DECLARE @BadResponseMessage NVARCHAR(300) = CONCAT('Estimado cliente, le comentamos que la guía FD', @GuideNumber, ' no ha sido procesada por CoD.');
	DECLARE @FailureResponseMessage NVARCHAR(300) = 'Estimado cliente, ha ocurrido un error al procesar su solicitud, por favor, intente de nuevo más tarde.';

	-- Tabla de respuesta
	DECLARE @ResponseTable AS TABLE(
		ReportCustomerId INT,
		ReportBankId INT,
		ReportStartDate DATETIME,
		ReportEndDate DATETIME,
		ReportOption INT,
		ReportMail NVARCHAR(200)
	);

	-- Varificar si la guía ya fue pagada
	DECLARE @GuideIsPaid BIT = ISNULL((
	SELECT
		TOP 1
			1
	FROM
		[DeliveryBackOffice].[dbo].[BatchDetailCOD] BDCOD WITH(NOLOCK)
	WHERE
		BDCOD.GuideSerie = @GuideSerie
		AND
		BDCOD.GuideNumber = @GuideNumber
		AND
		BDCOD.AuthorizationDate IS NOT NULL
	), 0)

	BEGIN TRY
		IF( @GuideIsPaid = 1 )
		BEGIN

			INSERT INTO
				@ResponseTable
				(ReportCustomerId, ReportBankId, ReportStartDate, ReportEndDate, ReportOption, ReportMail)
			SELECT
				TOP 1
					ISNULL(Cu.IdCustomer, -1) 'CustomerId'
					,BDCOD.BankId 'GuideBankId'
					,DATEADD(MONTH, DATEDIFF(MONTH, 0, BDCOD.AuthorizationDate), 0) 'StartDate'
					,BDCOD.AuthorizationDate 'EndDate'
					,-1 'Option'
					,(
						CASE
							WHEN Cu.IdCustomerType = 1 AND Cu.CODContactEmail IS NOT NULL THEN ISNULL(Cu.CODContactEmail,Cu.ContactEmail)
							ELSE ISNULL(DO.Sender_Mail, '')
						END
					) 'CustomerMail'
			FROM
				[DeliveryBackOffice].[dbo].[BatchDetailCOD] BDCOD WITH(NOLOCK)
				INNER JOIN
					[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
					ON
						BDCOD.GuideSerie = DO.Guide_Serie
						AND
						BDCOD.GuideNumber = DO.Guide_Number
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH(NOLOCK)
					ON
						DO.Sender_ID = VPC.CodeOfReference
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK)
					ON
						ISNULL(DO.IdCustomer, VPC.CustomerID) = Cu.IdCustomer
			WHERE
				BDCOD.GuideSerie = @GuideSerie
				AND
				BDCOD.GuideNumber = @GuideNumber
				AND
				BDCOD.AuthorizationDate IS NOT NULL
			ORDER BY
				BDCOD.AuthorizationDate DESC

			IF( EXISTS (SELECT TOP 1 1 FROM @ResponseTable) )
			BEGIN

				SELECT
					TOP 1
						1 [blnResult]
						,REPLACE(@GoodResponseMessage,'<MAIL>',RT.ReportMail) [messageResult]
						,@BadResponseMessage [badMessageResult]
						,@FailureResponseMessage [errorMessageResult]
						,RT.ReportCustomerId
						,RT.ReportBankId
						,CONVERT(NVARCHAR, RT.ReportStartDate, 120) 'ReportStartDate'
						,CONVERT(NVARCHAR, RT.ReportEndDate, 120) 'ReportEndDate'
						,RT.ReportOption
						,RT.ReportMail
						,@PHONE PHONE
						,@SoportMail SoportMail
				FROM
					@ResponseTable RT

			END
			ELSE
			BEGIN

				SELECT
					0 [blnResult] -- Indica que no se generará el reporte de CoD
					,@BadResponseMessage [messageResult]

			END

		END
		ELSE
		BEGIN

			SELECT
				0 [blnResult] -- Indica que no se generará el reporte de CoD
				,@BadResponseMessage [messageResult]

		END
	END TRY
	BEGIN CATCH

		SELECT
			0 [blnResult] -- Indica que no se generará el reporte de CoD
			,@FailureResponseMessage [messageResult]

	END CATCH
END;