

-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-02-17>
-- Description:	< obtiene de la bitácora de acciones pendientes los registro a procesar bajo su tipo de accion >
-- =============================================
CREATE PROCEDURE [dbo].[GetExternalPlatformServicePendingAction]
	@ExternalPlatform AS INT,
	@PendingAction AS INT,
	@Date DATETIME = NULL
AS
BEGIN

	IF(@Date IS NULL)
	BEGIN
		SET @Date = GETDATE()
	END

	IF(@PendingAction = 1) -- SERVICIOS POR INGRESAR
	BEGIN

		SELECT
			EPSPAL.GuideSerie
			,EPSPAL.GuideNumber
			,@PendingAction 'PendingAction'
			,'INSERT' 'PendingActionText'
		FROM
			[DeliveryBackOffice].[dbo].[ExternalPlatformServicePendingActionLog] EPSPAL WITH(NOLOCK)
		WHERE
			EPSPAL.RowStatus = 1
			AND
			EPSPAL.IsPendingInsert = 1
			AND
			CAST(EPSPAL.DateCreated AS DATE) = CAST(@Date AS DATE)

	END
	ELSE IF (@PendingAction = 2 ) -- SERVICIOS POR ACTUALIZAR
	BEGIN

		SELECT
			EPSPAL.GuideSerie
			,EPSPAL.GuideNumber
			,@PendingAction 'PendingAction'
			,'UPDATE' 'PendingActionText'
		FROM
			[DeliveryBackOffice].[dbo].[ExternalPlatformServicePendingActionLog] EPSPAL WITH(NOLOCK)
		WHERE
			EPSPAL.RowStatus = 1
			AND
			EPSPAL.IsPendingUpdate = 1
			AND
			CAST(EPSPAL.DateCreated AS DATE) = CAST(@Date AS DATE)

	END
	ELSE IF (@PendingAction = 3) -- SERVICIOS POR ELIMINAR
	BEGIN

		SELECT
			EPSPAL.GuideSerie
			,EPSPAL.GuideNumber
			,@PendingAction 'PendingAction'
			,'DELETE' 'PendingActionText'
		FROM
			[DeliveryBackOffice].[dbo].[ExternalPlatformServicePendingActionLog] EPSPAL WITH(NOLOCK)
		WHERE
			EPSPAL.RowStatus = 1
			AND
			EPSPAL.IsPendingDelete = 1
			AND
			CAST(EPSPAL.DateCreated AS DATE) = CAST(@Date AS DATE)

	END
	ELSE -- ACCIÓN NO PERMITIDA
	BEGIN
		SELECT
			0 [blnResult],
			0 AS [ErrorNumber],
			0 AS [ErrorSeverity],
			0 AS [ErrorState],
			0 AS [ErrorProcedure],
			0 AS [ErrorLine],
			'Acción no existente para servicio' AS [ErrorMessage];
	END
END
