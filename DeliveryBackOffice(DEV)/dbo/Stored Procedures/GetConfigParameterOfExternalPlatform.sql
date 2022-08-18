


-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-06-13>
-- Description:	< Recupera datos de configuración para plataformas externas >
-- =============================================

CREATE PROCEDURE [dbo].[GetConfigParameterOfExternalPlatform]
    @PlatformName NVARCHAR(50),
	@ParameterList TblExtPlatTextParameterList READONLY
AS
BEGIN

	-- Variables de respuesta
	DECLARE @ResponseData AS TABLE(
		ParameterName NVARCHAR(50),
		ParameterValue NVARCHAR(600),
		ParameterDate DATETIME
	);

	BEGIN TRY

		INSERT INTO
			@ResponseData
			(ParameterName, ParameterValue, ParameterDate)
		SELECT
			ConfEP.ConfigParameterName, ConfEP.ConfigParameterValue, ConfEP.ConfigMaxValidDate
		FROM
			[DeliveryBackOffice].[dbo].[ConfigExternalPlatform] ConfEP WITH(NOLOCK)
			LEFT JOIN
				@ParameterList PL
				ON
					ConfEP.ConfigParameterName = PL.TextParameter COLLATE Latin1_General_CI_AI
			INNER JOIN
				[DeliveryBackOffice].[dbo].[CatExternalPlatform] CEP WITH(NOLOCK)
				ON
					ConfEP.ExternalPlatformId = CEP.IdExternalPlatform
					AND
					CEP.RowStatus = 1
		WHERE
			CEP.NameExternalPlatform = @PlatformName COLLATE Latin1_General_CI_AI
			AND
			ConfEP.RowStatus = 1

		IF( EXISTS( SELECT TOP 1 1 FROM @ResponseData ) )
		BEGIN

			SELECT
				CAST(1 AS BIT) [blnResult],
				RD.ParameterName,
				RD.ParameterValue
			FROM
				@ResponseData RD

		END
		ELSE
		BEGIN

			SELECT 
				CAST(0 AS BIT) [blnResult],
				-1 AS [ErrorNumber],
				-1 AS [ErrorSeverity],
				-1 AS [ErrorState],
				'GetConfigParameterOfExternalPlatform' AS [ErrorProcedure],
				50 AS [ErrorLine],
				'No se obtuvieron datos de los parametros especificados' AS [ErrorMessage];

		END

	END TRY
	BEGIN CATCH

        SELECT 
			CAST(0 AS BIT) [blnResult],
            ERROR_NUMBER() AS [ErrorNumber],
            ERROR_SEVERITY() AS [ErrorSeverity],
            ERROR_STATE() AS [ErrorState],
            ERROR_PROCEDURE() AS [ErrorProcedure],
            ERROR_LINE() AS [ErrorLine],
            ERROR_MESSAGE() AS [ErrorMessage];

	END CATCH

END;