/* =================================================
   SP:        CheckStatusForWorkflow
   Propósito: Se verifica si el estado de la guia es parte de los estados del flujo de trabajo
   Autor:     Erick Hernandez
   Historia:  FDAPI-5684
   Fecha:     2026-03-11

=== CHANGELOG ============================
2026-04-24 | Historia/épica: FDAPI-6130 | Autor: Erick Hernandez | Se obtiene país de DeliveryOrder y se agrega validación de código del país
=========================================== */
CREATE PROCEDURE [dbo].[CheckStatusForWorkflow]
	@WorkflowID BIGINT,
	@GuideSeries NVARCHAR(2),
    @GuideNumber INT
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @RowStatus_Active INT = 1;

	DECLARE @GuideStatusOrderID INT = 0;
	DECLARE @CurrentStatus NVARCHAR(50);
	DECLARE @CountryId VARCHAR(10) = NULL;

	SELECT @GuideStatusOrderID = DO.StatusOrderId, @CurrentStatus = S.OrderDescription,
	@CountryId = CASE 
		WHEN DO.SenderCountryId = DO.ReceiverCountryId THEN DO.ReceiverCountryId
		ELSE NULL
	END
	FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH (NOLOCK)
	INNER JOIN DeliveryBackOffice.dbo.StatusOrder S WITH (NOLOCK)
		ON S.StatusOrderId = DO.StatusOrderId
	WHERE DO.Guide_Serie = @GuideSeries
	AND DO.Guide_Number = @GuideNumber;
	
	IF @GuideStatusOrderID IS NULL
    BEGIN
        SELECT 0 AS IsAllowed, NULL AS CurrentStatus;
        RETURN;
    END

	IF @CountryId IS NULL
    BEGIN
        SELECT 0 AS IsAllowed, NULL AS CurrentStatus;
        RETURN;
    END
	
	IF NOT EXISTS (SELECT 1 FROM DeliveryBackOffice.dbo.CatCountry WITH (NOLOCK) WHERE IdCountry = @CountryId AND CountryRowStatus = @RowStatus_Active)
	BEGIN
		SELECT 0 AS IsAllowed, NULL AS CurrentStatus;
		RETURN;
	END

	IF EXISTS
    (
        SELECT 1
        FROM WorkflowStatusMap WITH (NOLOCK)
        WHERE StatusOrderId = @GuideStatusOrderID
        AND WorkflowId = @WorkflowID
		AND CountryId = @CountryId
        AND RowStatus = 1
    )
    BEGIN
        SELECT 1 AS IsAllowed, @CurrentStatus AS CurrentStatus;
    END
    ELSE
    BEGIN
        SELECT 0 AS IsAllowed, @CurrentStatus AS CurrentStatus;
    END
END;