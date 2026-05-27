/* =================================================
   SP:        [dbo].[SaveDeliveryManifestAssistant]
   Propósito: Se agregan asistentes/auxiliares a un manifiesto de entrega.
   Autor:     Erick Hernandez
   Historia:  FDAPI-6114
   Fecha:     2026-05-19
   === CHANGELOG ============================
=========================================== */
CREATE PROCEDURE [dbo].[SaveDeliveryManifestAssistant]
	@AssistantIdList NVARCHAR(MAX),
    @ManifestID INT,
	@Token NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		DECLARE @AssistantIds TABLE (ID INT);
		DECLARE @RowStatus_Active INT = 1;
		
		INSERT INTO @AssistantIds
		SELECT DISTINCT LTRIM(RTRIM(Item))
		FROM DeliveryBackOffice.dbo.SplitUnlimited(@AssistantIdList, ',');
		
		INSERT INTO DeliveryBackOffice.dbo.DeliveryManifestAssistantAssignment
		(DeliveryManifestId, CourierAssistantId, DateCreated, TokenCreated, RowStatus)
		SELECT @ManifestID, A.ID, GETDATE(), @Token, @RowStatus_Active
		FROM @AssistantIds A
		WHERE NOT EXISTS
		(
			SELECT 1
			FROM DeliveryBackOffice.dbo.DeliveryManifestAssistantAssignment EA WITH(NOLOCK)
			WHERE EA.DeliveryManifestId = @ManifestID
				AND EA.CourierAssistantId = A.ID
				AND EA.RowStatus = @RowStatus_Active
		);
		
		SELECT @@ROWCOUNT AS RowsAffected;
	END TRY
	BEGIN CATCH
		SELECT -1 AS RowsAffected;
	END CATCH	
END