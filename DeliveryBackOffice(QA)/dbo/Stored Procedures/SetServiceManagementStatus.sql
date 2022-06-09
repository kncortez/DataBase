-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-02-09>
-- Description:	<Cambia el estado de una solicitud de recolección>
-- =============================================
CREATE PROCEDURE [dbo].[SetServiceManagementStatus]
	-- Add the parameters for the stored procedure here
	@SchedulePickupId BIGINT,
	@Status NVARCHAR(100),
	@Token NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Control actualización
	DECLARE @RModified INT

	DECLARE @ServiceManagementId INT
	DECLARE @StatusOld INT
	DECLARE @StatusNew INT

	BEGIN TRY

		SELECT
			@ServiceManagementId = sm.IdServiceManagement
		   ,@StatusOld = sm.ServiceStatusId
		FROM ServiceManagement sm
		WHERE sm.IdSchedulePickup = @SchedulePickupId

		IF @Status <> 'Cancelado'
		BEGIN
			SET @StatusNew = (SELECT TOP 1
					smsl.ServiceStatusIdOld
				FROM ServiceManagementStatusLog smsl
				WHERE smsl.ServiceManagementId = @ServiceManagementId
				ORDER BY smsl.DateCreated DESC)
		END

		IF @StatusNew IS NULL
			SET @StatusNew = (SELECT
					IdServiceStatus
				FROM CatServiceStatus
				WHERE Name = @Status)
		ELSE
			SELECT 
				@Status = css.Name
			FROM CatServiceStatus css
			WHERE css.IdServiceStatus = @StatusNew


		UPDATE ServiceManagement
		SET ServiceStatusId = @StatusNew
		WHERE IdSchedulePickup = @SchedulePickupId

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

		INSERT INTO [dbo].[ServiceManagementStatusLog] ([ServiceManagementId]
		, [ServiceStatusIdOld]
		, [ServiceStatusIdNew]
		, [RowStatus]
		, [TokenCreated]
		, [DateCreated]
		, [TokenUpdated]
		, [DateUpdated])
			VALUES (@ServiceManagementId, @StatusOld, @StatusNew, 1, @Token, GETDATE(), NULL, NULL)

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
