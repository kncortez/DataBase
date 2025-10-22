-- =============================================  
-- Author:		<Brandon, Pedroza>  
-- Create date: <2025-01-13>  
-- Description: <Contenerizacion guias - Obtener guias de un contenedor>  
-- =============================================  
CREATE PROCEDURE [dbo].[sphwGetGuidesByContainer]
    @ReferencesContainer NVARCHAR(50),
    @IdCountry NVARCHAR(5)
AS
BEGIN
    SET NOCOUNT ON;
	DECLARE @IdContainerLiquid INT;
	DECLARE @IdStatusGenerated INT= (SELECT StatusOrderId FROM StatusOrder WITH(NOLOCK) WHERE OrderDescription = 'Solicitado');
	DECLARE @IdStatusRequest INT= (SELECT StatusOrderId FROM StatusOrder WITH(NOLOCK) WHERE OrderDescription = 'Generado');
	DECLARE @IdStatusPickUp INT= (SELECT StatusOrderId FROM StatusOrder WITH(NOLOCK) WHERE OrderDescription = 'Recolectado');

	SET @IdContainerLiquid = (SELECT IdCatStatus FROM CatShipContainerStatus WITH(NOLOCK) WHERE [Name] = 'Liquidado')
	IF EXISTS(SELECT 1 FROM ShippingContainer SC WITH (NOLOCK)
				WHERE SC.ReferenceContainer = @ReferencesContainer
				AND IdStatusContainer = @IdContainerLiquid)
	BEGIN

		SELECT 0 AS StatusCode,
				'El contenedor'+@ReferencesContainer+' ya ha sido liquidado' AS [Description]
				RETURN
	END
	IF NOT EXISTS(SELECT 1 FROM ShippingContainer SC WITH (NOLOCK)  
			INNER JOIN Customer CU WITH(NOLOCK)  
			ON SC.IdCustomer = CU.IdCustomer  
			WHERE SC.ReferenceContainer = @ReferencesContainer)  
	BEGIN  
	SELECT 2 AS StatusCode,  
		'El contenedor '+@ReferencesContainer+' no existe. ' AS [Description]  
		RETURN
	END  

	IF EXISTS(SELECT 1 FROM ShippingContainer SC WITH (NOLOCK)
						INNER JOIN Customer CU WITH(NOLOCK)
						ON SC.IdCustomer = CU.IdCustomer
				WHERE SC.ReferenceContainer = @ReferencesContainer
				AND ISNULL(CU.CountryID, 'GT')<> @IdCountry)
	BEGIN

		SELECT 1 AS StatusCode,
				'El contenedor '+@ReferencesContainer+' pertenece a otro país' AS [Description]
		RETURN
	END

SELECT		200 AS StatusCode,
			DO.Guide_Serie AS GuideSerie
			,DO.Guide_Number AS GuideNumber
			,DOP.NoPiece AS GuidePieces
			--,(DO.Pieces_Cold + DO.Pieces_Dry) AS GuidePieces
			,ISNULL(DO.Ticket_Number, '') AS TicketNumber
			,ISNULL(DO.Ticket_Number, '') AS [Description]
			,DO.DateCreated
			,ISNULL(A2.[Name], A2.[Description]) AS Customer
			,ISNULL(CAT.[Name], 'Pendiente') AS StatusGuide
			,SC.IdCustomer AS IdCustomer
			,ISNULL(DOP.IsNewInContainer, '0') AS NewRegister
FROM DeliveryOrder DO WITH (NOLOCK)
	INNER JOIN Customer A2 WITH (NOLOCK) 
		ON DO.IdCustomer = A2.IdCustomer
	INNER JOIN DeliveryOrderPiece DOP WITH(NOLOCK)
		ON DO.Guide_Serie = DOP.GuideSerie
		AND DO.Guide_Number = DOP.GuideNumber
	INNER JOIN ShippingContainerDetail SCD WITH(NOLOCK)
		ON SCD.GuideNumber = DO.Guide_Number
		AND SCD.GuideSerie = DO.Guide_Serie
	INNER JOIN ShippingContainer SC WITH (NOLOCK)
		ON SC.IdContainer = SCD.IdContainer
	LEFT JOIN CatStatusGuideByContainer CAT WITH(NOLOCK)
		ON CAT.IdStatus = DOP.IdStatusGuideByContainer
WHERE SC.ReferenceContainer = @ReferencesContainer
	AND SCD.RowStatus = 1 
	AND SC.RowStatus = 1
	AND DO.StatusOrderId IN (@IdStatusGenerated,@IdStatusRequest,@IdStatusPickUp)

END;
