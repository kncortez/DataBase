-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2024-03-08>
-- Description:	<Cargar datos de los codigos de pieza de Forza con DHL por usuario del día solicitado>
-- =============================================

CREATE PROCEDURE [dbo].[sp_Get_RelationshipPieceCode]
    @AccountId	BIGINT,
    @Date		DATE
AS
BEGIN
	BEGIN TRY
	
		SELECT  
			CONCAT(DOP.[GuideSerie], DOP.[GuideNumber])						AS 'GuideForza',
			DO.[Ticket_Number]												AS 'GuideDHL',
			COALESCE(DO.[Pieces_Dry],0) + COALESCE(DO.[Pieces_Cold],0)		AS 'CountPieces',
			CONCAT(DOP.[GuideSerie], DOP.[GuideNumber],'-',DOP.[NoPiece])	AS 'PieceForza',
			DOP.[ExternalPieceId]											AS 'PieceDHL'
		FROM [DeliveryBackOffice].[dbo].[Account] A WITH(NOLOCK)
			INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK) 
				ON DO.[IdCustomer] = A.[IdCustomer]
			INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOP WITH(NOLOCK)
				ON DOP.[GuideSerie] = DO.[Guide_Serie] AND DOP.[GuideNumber] = DO.[Guide_Number]
		WHERE 
			A.[AccRowStatus] = 1 
			AND A.[AccIdAccount] = @AccountId 
			AND CAST(DOP.[DateRegistrationExternalCode] AS DATE) = @Date
		ORDER BY DOP.[GuideNumber], DOP.[NoPiece]

	END TRY
	BEGIN CATCH
		SELECT
				ERROR_MESSAGE() AS 'GuideForza',
				'' AS 'GuideDHL',
				0 AS 'CountPieces',
				'' AS 'PieceForza',
				'' AS 'PieceDHL'
	END CATCH;
END