-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-02-09>
-- Description:	<Cambia el estado de una solicitud de recolección>
-- =============================================
CREATE PROCEDURE [dbo].[SetSchedulePickupStatus]
	-- Add the parameters for the stored procedure here
	@SchedulePickupId BIGINT,
	@Status BIT,
	@Token NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Control actualización
	DECLARE @RModified INT

	BEGIN TRY

		UPDATE SchedulePickup
		SET	
			SchedulePickupStatus = @Status
		WHERE SchedulePickupId = @SchedulePickupId

		SET @RModified = @@ROWCOUNT
	END TRY
	BEGIN CATCH
	SELECT 
			0 'StatusCode', 
			ERROR_MESSAGE() 'Description', 
			@Status 'Status'
	END CATCH

	IF (@RModified > 0)
	BEGIN

		INSERT INTO [dbo].[SchedulePickupStatusLog] ([SchedulePickupId]
		, [SchedulePickupStatus]
		, [RowStatus]
		, [TokenCreated]
		, [DateCreated]
		, [TokenUpdated]
		, [DateUpdated])
			VALUES (@SchedulePickupId, @Status, 1, @Token, GETDATE(), NULL, NULL)

		SELECT			  
			1 'StatusCode',
			'Registro actualizado correctamente' 'Description', 
			@Status 'Status'
	END
	ELSE
		SELECT			  
			0 AS 'StatusCode',
			'Registro no encontrado' AS 'Description', 
			@Status 'Status'

END
