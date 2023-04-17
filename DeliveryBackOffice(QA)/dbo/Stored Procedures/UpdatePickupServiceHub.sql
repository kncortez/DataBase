

-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-09-22>
-- Last Update date: <2022-09-22>
-- Description:	< Login de portal web para usuarios internos >
-- =============================================

CREATE PROCEDURE [dbo].[UpdatePickupServiceHub]
	-- Add the parameters for the stored procedure here
	@ServiceManagementId INT = 0,
	@HubDestinyId INT, 
	@Token NVARCHAR(50)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	DECLARE @UpdatedPickup AS TABLE(
		UpdatedId INT
	);

	BEGIN TRANSACTION
	BEGIN TRY

		UPDATE
			SP
		SET
			SP.IdHubLogistics = @HubDestinyId,
			SP.TokenUpdated = @Token,
			SP.DateUpdated = GETDATE()
		OUTPUT inserted.SchedulePickupId INTO @UpdatedPickup(UpdatedId)
		FROM
			[DeliveryBackOffice].[dbo].[ServiceManagement] SM WITH(NOLOCK)
			INNER JOIN
				[DeliveryBackOffice].[dbo].[SchedulePickup] SP WITH(NOLOCK)
				ON
					SM.IdSchedulePickup = SP.SchedulePickupId
		WHERE
			SM.IdServiceManagement = @ServiceManagementId

		IF (EXISTS (SELECT TOP 1 1 FROM @UpdatedPickup))
		BEGIN

			SELECT
				200 [resultCode],
				'Cambio realizado exitosamente' [resultMessage]

			COMMIT TRANSACTION;

		END
		ELSE
		BEGIN

			ROLLBACK TRANSACTION;

			SELECT
				404 [resultCode],
				'Actualización no fue realizada' [resultMessage]

		END

	END TRY
	BEGIN CATCH

		ROLLBACK TRANSACTION;

		SELECT
			500 [resultCode],
			ERROR_MESSAGE() [resultMessage]

	END CATCH

END;