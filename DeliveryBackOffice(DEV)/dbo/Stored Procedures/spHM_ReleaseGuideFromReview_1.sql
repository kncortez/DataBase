-- =============================================
-- Author:		<Freddy Camposeco>
-- Create date: <2025-12-02>
-- Description:	<Libera guías desde estado "En Revisión" en contexto de linehaul sin validaciones de liquidación>
-- =============================================
CREATE   PROCEDURE [dbo].[spHM_ReleaseGuideFromReview]
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT,
	@TargetStatusId INT = NULL, -- Si es NULL, usa el estado por defecto de liberación
	@TknUser NVARCHAR(50),
	@Observations NVARCHAR(200) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @StatusRevision INT = 13; -- "En Revisión"
	DECLARE @StatusLiberacion INT;
	DECLARE @CurrentStatusId INT;
	DECLARE @GuideExists BIT = 0;
	DECLARE @IsInLinehaul BIT = 0;

	DECLARE @ErrorCode INT = 0;
	DECLARE @ErrorDescription NVARCHAR(200);

	BEGIN TRANSACTION

	BEGIN TRY

		-- Verificar si la guía existe
		SELECT
			@GuideExists = 1,
			@CurrentStatusId = DO.StatusOrderId
		FROM DeliveryOrder DO WITH (NOLOCK)
		WHERE DO.Guide_Serie = @GuideSerie
		AND DO.Guide_Number = @GuideNumber;

		IF @GuideExists = 0
		BEGIN
			SET @ErrorCode = 1;
			SET @ErrorDescription = 'La guía no existe.';
			RAISERROR(@ErrorDescription, 16, 1);
		END

		-- Verificar que esté en estado "En Revisión"
		IF @CurrentStatusId <> @StatusRevision
		BEGIN
			SET @ErrorCode = 2;
			SET @ErrorDescription = 'La guía no está en estado "En Revisión".';
			RAISERROR(@ErrorDescription, 16, 1);
		END

		-- Verificar que la guía esté en preparación de linehaul
		SELECT
			@IsInLinehaul = 1
		FROM LinehaulRoutePreparationContainerDetail LRPCD WITH (NOLOCK)
		WHERE LRPCD.GuideSerie = @GuideSerie
		AND LRPCD.GuideNumber = @GuideNumber;

		IF @IsInLinehaul = 0
		BEGIN
			SET @ErrorCode = 3;
			SET @ErrorDescription = 'La guía no está en preparación de linehaul.';
			RAISERROR(@ErrorDescription, 16, 1);
		END

		-- Determinar el estado destino
		IF @TargetStatusId IS NULL
		BEGIN
			-- Usar directamente el estado con ID 44 (Liberación)
			SET @StatusLiberacion = 44;
			SET @TargetStatusId = @StatusLiberacion;
		END

		-- Actualizar estado de todas las piezas de la guía
		UPDATE DeliveryOrderPiece
		SET StatusOrderId = @TargetStatusId
		WHERE GuideSerie = @GuideSerie
		AND GuideNumber = @GuideNumber;

		-- Actualizar estado de la guía
		UPDATE DeliveryOrder
		SET StatusOrderId = @TargetStatusId
		WHERE Guide_Serie = @GuideSerie
		AND Guide_Number = @GuideNumber;

		-- Registrar en histórico
		INSERT INTO DeliveryOrderDetail (
			Guide_Serie,
			Guide_Number,
			StatusOrderId,
			UserCreated,
			DateCreated,
			DateCreatedInSystem,
			Observations,
			RowStatus
		)
		VALUES (
			@GuideSerie,
			@GuideNumber,
			@TargetStatusId,
			@TknUser,
			GETDATE(),
			GETDATE(),
			@Observations,
			1
		);

		COMMIT TRANSACTION;

		-- Retornar éxito
		SELECT
			1 AS StatusCode,
			'Guía liberada correctamente.' AS Description,
			@TargetStatusId AS NewStatusId,
			(SELECT OrderDescription FROM StatusOrder WHERE StatusOrderId = @TargetStatusId) AS NewStatusDescription;

	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		SELECT
			@ErrorCode AS StatusCode,
			COALESCE(@ErrorDescription, ERROR_MESSAGE()) AS Description,
			ERROR_NUMBER() AS ErrorNumber,
			ERROR_LINE() AS ErrorLine;

	END CATCH
END