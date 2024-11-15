-- =============================================
-- Author:		<Oscar Rodriguez>
-- Create date: <2024-11-14>
-- Description:	<Actualizacion de fecha de notificacion para guias subscritas y estado final para cierre de notificaciones>
-- =============================================
CREATE PROCEDURE [dbo].[sphwUpdateStatusNotifications]
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT,
	@NirPhone NVARCHAR(6),
	@Phone INT,
	@DateCreated DATETIME,
	@StatusDescription NVARCHAR(200)
AS
BEGIN
	IF @StatusDescription IN (
		SELECT OrderDescription 
		FROM DeliveryBackOffice.dbo.StatusOrder  WITH(NOLOCK)
		WHERE CATStatusTypeId = 2
		AND CatCheckpointTypeId = 3
	)
	BEGIN
		BEGIN TRANSACTION;
			UPDATE DeliveryBackOffice.dbo.GuideStatusNotification
			SET LastChangeDate = @DateCreated,
				FinalStatus = 1
			WHERE GuideSerie = @GuideSerie
			AND GuideNumber = @GuideNumber
			AND NirPhoner= @NirPhone
			AND Phone= @Phone
			AND LastChangeDate < @DateCreated
		COMMIT TRANSACTION  
	END 
	ELSE
	BEGIN
		BEGIN TRANSACTION;
			UPDATE DeliveryBackOffice.dbo.GuideStatusNotification
			SET LastChangeDate = @DateCreated
			WHERE GuideSerie = @GuideSerie
			AND GuideNumber = @GuideNumber
			AND NirPhoner= @NirPhone
			AND Phone= @Phone
			AND LastChangeDate < @DateCreated
		COMMIT TRANSACTION 
	END
END;
