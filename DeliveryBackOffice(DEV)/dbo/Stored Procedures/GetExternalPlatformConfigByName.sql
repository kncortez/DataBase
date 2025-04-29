-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-11-18>
-- Description:	< Obtener datos de configuración de elemento especifico de plataformas externas >
-- =============================================
CREATE PROCEDURE [dbo].[GetExternalPlatformConfigByName]

    @ExternalPlatformId INT = NULL,
	@ExternalPlatformName NVARCHAR(50) = NULL,
	@ExternalPlatformConfigName NVARCHAR(50) = NULL
AS
BEGIN
	DECLARE @ConfigData TABLE (
		ExternalPlatformId INT,
		ExternalPlatformName NVARCHAR(50),
		ConfigId INT,
		ExternalPlatformConfig NVARCHAR(50),
		ExternalPlatformConfigValue NVARCHAR(600)
	);
	BEGIN TRY
		IF(@ExternalPlatformId IS NOT NULL OR @ExternalPlatformName IS NOT NULL OR @ExternalPlatformConfigName IS NOT NULL)
		BEGIN
		
			INSERT INTO @ConfigData
				(ExternalPlatformId, ConfigId, ExternalPlatformName, ExternalPlatformConfig, ExternalPlatformConfigValue)
			SELECT
				CEP.IdExternalPlatform, ConfEP.IdConfigExternalPlatform, CEP.NameExternalPlatform, ConfEP.ConfigParameterName, ConfEP.ConfigParameterValue
			FROM
				[DeliveryBackOffice].[dbo].[ConfigExternalPlatform] ConfEP WITH(NOLOCK)
				INNER JOIN
					[DeliveryBackOffice].[dbo].[CatExternalPlatform] CEP WITH(NOLOCK)
					ON
						ConfEP.ExternalPlatformId = CEP.IdExternalPlatform
			WHERE
				(@ExternalPlatformId IS NULL OR CEP.IdExternalPlatform = @ExternalPlatformId)
				AND
				(@ExternalPlatformName IS NULL OR CEP.NameExternalPlatform = @ExternalPlatformName) --COLLATE Latin1_General_CI_AI)
				AND
				(@ExternalPlatformConfigName IS NULL OR @ExternalPlatformConfigName = ConfEP.ConfigParameterName AND ConfEP.RowStatus = 1)
			IF (EXISTS(SELECT TOP 1 1 FROM @ConfigData))
			BEGIN
				SELECT
					200 'CodeResult',
					'Datos encontrados para la configuración indicada' 'MessageResult'
				SELECT
					CD.ExternalPlatformId,
					CD.ExternalPlatformName,
					CD.ConfigId,
					CD.ExternalPlatformConfig,
					CD.ExternalPlatformConfigValue
				FROM
					@ConfigData CD
			END
			ELSE
			BEGIN
				SELECT
					204 'CodeResult',
					'No se encontro información para el dato solicitado' 'MessageResult'
			END
		END
		ELSE
		BEGIN
			SELECT
				204 'CodeResult',
				'No se encontro información para el dato solicitado' 'MessageResult'
		END
	END TRY
	BEGIN CATCH
		SELECT
			500 'CodeResult',
			ERROR_MESSAGE() 'MessageResult'
	END CATCH
END;