
-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-09-06>
-- Description:	<Obtiene información de la preparación de una ruta de entregas en móvil>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_GetRoutePreparation]
	-- Add the parameters for the stored procedure here
	@RouteId INT,
	@Date DATE
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	set arithabort on;
	IF EXISTS (SELECT TOP 1 1 FROM RoutePreparation WHERE CatRouteId = @RouteId AND DateRoutePreparation = @DATE)
	BEGIN
		SELECT
			1 'StatusCode'
		   ,'Successfull' 'Description'

		--TABLE 1 Información de la preparación de la ruta
		SELECT
			rp.IdRoutePreparation
		   ,rp.GuidesQuantity
		   ,rp.PiecesDry
		   ,rp.PiecesCold
		   ,rp.DeliveryOrderBySettlementId
		FROM RoutePreparation rp WITH (NOLOCK)
		WHERE rp.CatRouteId = @RouteId
		AND rp.DateRoutePreparation = @Date
		AND rp.RowStatus = 1

		--TABLE 2 Información de las guías en preparación de la ruta
		SELECT
			rpd.IdRoutePreparationDetail 'IdRoutePreparationDetail'
		   ,rpd.Guide_Serie 'GuideSerie'
		   ,rpd.Guide_Number 'GuideNumber'
		   ,COUNT(1) 'Pieces'
		   ,COALESCE(do.Pieces_Dry, 0) + COALESCE(do.Pieces_Cold, 0) 'PiecesTotal'
		   ,do.Receiver_Department 'Department'
		   ,do.Receiver_Town 'Town'
		   ,do.Receiver_Address 'Address'
		   ,rpd.GuideOrder 'GuideOrder'
		   ,do.Ticket_Number
		FROM RoutePreparation rp WITH (NOLOCK)
		INNER JOIN RoutePreparationDetail rpd WITH (NOLOCK)
			ON rpd.RoutePreparationId = rp.IdRoutePreparation
				AND rpd.RowStatus = 1
		INNER JOIN RoutePreparationDetailPiece rpdp WITH (NOLOCK)
			ON rpdp.RoutePreparationDetailId = rpd.IdRoutePreparationDetail
				AND rpdp.RowStatus = 1
		INNER JOIN DeliveryOrder do WITH (NOLOCK)
			ON rpd.Guide_Serie = do.Guide_Serie
				AND rpd.Guide_Number = do.Guide_Number
		WHERE rp.CatRouteId = @RouteId
		AND rp.DateRoutePreparation = @Date
		AND rp.RowStatus = 1
		GROUP BY IdRoutePreparationDetail
				,rpd.Guide_Serie
				,rpd.Guide_Number
				,do.Pieces_Dry
				,do.Pieces_Cold
				,do.Receiver_Department
				,do.Receiver_Town
				,do.Receiver_Address
				,rpd.GuideOrder
				,do.Ticket_Number
		ORDER BY COALESCE(rpd.GuideOrder, 999999) ASC 
	END
	ELSE
	BEGIN 
		SELECT
			2 'StatusCode'
		   ,'Records not found' 'Description'
	END
END