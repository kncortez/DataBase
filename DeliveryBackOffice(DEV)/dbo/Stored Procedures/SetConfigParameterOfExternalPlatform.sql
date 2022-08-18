


-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-06-13>
-- Description:	< Actualiza datos de configuración para plataformas externas >
-- =============================================

CREATE PROCEDURE [dbo].[SetConfigParameterOfExternalPlatform]
    @PlatformName NVARCHAR(50),
	@Token NVARCHAR(50),
	@ParameterList TblExtPlatTextParameterSetList READONLY
AS
BEGIN

	DECLARE @UpdatedRows INT = 0;

	BEGIN TRANSACTION
	BEGIN TRY

		INSERT INTO
			[DeliveryBackOffice].[dbo].[ConfigExternalPlatform]
			(ExternalPlatformId, ConfigParameterName, ConfigParameterValue, ConfigMaxValidDate, RowStatus, DateCreated, TokenCreated)
		SELECT
			CEP.IdExternalPlatform, PL.TextParameter, PL.TextParameterValue, PL.TextParameterDate, 1, GETDATE(), @Token
		FROM
			@ParameterList PL
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[ConfigExternalPlatform] ConfEP WITH(NOLOCK)
				ON
					ConfEP.ConfigParameterName = PL.TextParameter COLLATE Latin1_General_CI_AI
					AND
					ConfEP.RowStatus = 1
			CROSS JOIN
				[DeliveryBackOffice].[dbo].[CatExternalPlatform] CEP WITH(NOLOCK)
		WHERE
			ConfEP.IdConfigExternalPlatform IS NULL
			AND
			CEP.NameExternalPlatform = @PlatformName COLLATE Latin1_General_CI_AI
			AND
			CEP.RowStatus = 1

		IF( SCOPE_IDENTITY() > 0 )
		BEGIN
			SET @UpdatedRows = @UpdatedRows + 1;
		END

		UPDATE
			ConfEP
		SET
			ConfEP.ConfigParameterValue = PL.TextParameterValue
			,ConfEP.DateUpdated = GETDATE()
			,ConfEP.TokenUpdated = @Token
		FROM	
			[DeliveryBackOffice].[dbo].[ConfigExternalPlatform] ConfEP WITH(NOLOCK)
			INNER JOIN
				@ParameterList PL
				ON
					ConfEP.ConfigParameterName = PL.TextParameter COLLATE Latin1_General_CI_AI
			INNER JOIN
				[DeliveryBackOffice].[dbo].[CatExternalPlatform] CEP WITH(NOLOCK)
				ON
					ConfEP.ExternalPlatformId = CEP.IdExternalPlatform
		WHERE
			CEP.NameExternalPlatform = @PlatformName COLLATE Latin1_General_CI_AI
			AND
			ConfEP.RowStatus = 1
			AND
			CEP.RowStatus = 1

		IF( @@ROWCOUNT > 0 )
		BEGIN
			SET @UpdatedRows = @UpdatedRows + @@ROWCOUNT;
		END

		IF( @UpdatedRows > 0 )
		BEGIN

			IF(@@TRANCOUNT > 0)
				COMMIT TRANSACTION;

			SELECT
				CAST(1 AS BIT) [blnResult]

		END
		ELSE
		BEGIN

			ROLLBACK TRANSACTION;

			SELECT 
				CAST(0 AS BIT) [blnResult],
				-1 AS [ErrorNumber],
				-1 AS [ErrorSeverity],
				-1 AS [ErrorState],
				'SetConfigParameterOfExternalPlatform' AS [ErrorProcedure],
				50 AS [ErrorLine],
				'No se actualizaron los parametros especificados' AS [ErrorMessage];

		END

	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;

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