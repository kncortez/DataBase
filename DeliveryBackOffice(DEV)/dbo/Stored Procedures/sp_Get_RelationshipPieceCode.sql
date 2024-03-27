-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2024-03-08>
-- Description:	<Cargar datos de los códigos de pieza de Forza con DHL por usuario del día solicitado>
-- =============================================

CREATE PROCEDURE [dbo].[sp_Get_RelationshipPieceCode]
    @AccountId	BIGINT,
    @Date		DATE
AS
BEGIN
	BEGIN TRY
	
		SELECT CONCAT(DOP.[GuideSerie], DOP.[GuideNumber]) [GuideForza],
			   TBL.[Ticket_Number] [GuideDHL],
			   TBL.CountPieces [CountPieces],
			   CONCAT(DOP.[GuideSerie], DOP.[GuideNumber], '-', DOP.[NoPiece]) [PieceForza],
			   DOP.[ExternalPieceId] [PieceDHL]
		FROM dbo.DeliveryOrderPiece DOP
			OUTER APPLY
		(
			SELECT DO.Guide_Serie,
				   DO.Guide_Number,
				   DO.Ticket_Number,
				   COALESCE(DO.[Pieces_Dry], 0) + COALESCE(DO.[Pieces_Cold], 0) CountPieces
			FROM [DeliveryBackOffice].[dbo].[Account] A WITH (NOLOCK)
				INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
					ON DO.[IdCustomer] = A.[IdCustomer]
			WHERE A.[AccRowStatus] = 1
				  AND A.[AccIdAccount] = @AccountId
				  AND EXISTS
			(
				SELECT 1
				FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOP2
				WHERE CAST(DOP2.[DateRegistrationExternalCode] AS DATE) = @Date
					  AND DOP2.[GuideSerie] = DO.[Guide_Serie]
					  AND DOP2.[GuideNumber] = DO.[Guide_Number]
					  AND DOP2.[AccountIdRegistrationExternalCode] = @AccountId
			)
		) TBL
		WHERE DOP.GuideSerie = TBL.Guide_Serie
			  AND DOP.GuideNumber = TBL.Guide_Number
		ORDER BY 1 ASC,4 ASC;

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