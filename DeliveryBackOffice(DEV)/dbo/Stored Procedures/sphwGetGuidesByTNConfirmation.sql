-- =============================================  
-- Author:		<Walter, Orozco>  
-- Modified:	<2025-02-21>  
-- Description: <Contenerizacion guias -Se obtienen guias por numero de ticket para confirmacion devolución/entrega >  
-- =============================================

CREATE PROCEDURE [dbo].[sphwGetGuidesByTNConfirmation]
    @TicketNumber NVARCHAR(50),
    @IdCountry NVARCHAR(5),
	@IdCustomer INT=0
AS
BEGIN
    SET NOCOUNT ON;

	IF @IdCustomer <> 0
	BEGIN
		SELECT 
			ISNULL(A1.Ticket_Number, '') AS TicketNumber,
			ISNULL(A2.[Name], A2.[Description]) AS Customer,
			A1.Guide_Number AS GuideNumber,
			A1.Guide_Serie AS GuideSerie, 
			(A1.Pieces_Cold + A1.Pieces_Dry) AS GuidePieces
		FROM DeliveryOrder A1 WITH (NOLOCK)
		INNER JOIN Customer A2 WITH (NOLOCK) 
			ON A1.IdCustomer = A2.IdCustomer
		WHERE A1.Ticket_Number = @TicketNumber
		  AND ISNULL(A1.SenderCountryId, 'GT') = @IdCountry
		  AND A1.IdCustomer = @IdCustomer
	END 
	ELSE
	BEGIN 
		SELECT 
			ISNULL(A1.Ticket_Number, '') AS TicketNumber,
			ISNULL(A2.[Name], A2.[Description]) AS Customer,
			A1.Guide_Number AS GuideNumber,
			A1.Guide_Serie AS GuideSerie, 
			(A1.Pieces_Cold + A1.Pieces_Dry) AS GuidePieces
		FROM DeliveryOrder A1 WITH (NOLOCK)
		INNER JOIN Customer A2 WITH (NOLOCK) 
			ON A1.IdCustomer = A2.IdCustomer
		WHERE A1.Ticket_Number = @TicketNumber
		  AND ISNULL(A1.SenderCountryId, 'GT') = @IdCountry
	END	
	IF NOT EXISTS(SELECT A1.Guide_Number			
		FROM DeliveryOrder A1 WITH (NOLOCK)
		INNER JOIN Customer A2 WITH (NOLOCK) 
			ON A1.IdCustomer = A2.IdCustomer
		WHERE A1.Ticket_Number = @TicketNumber)
	BEGIN
		SELECT 1 AS [StatusCode] ,
				CONCAT('La referencia: ', @TicketNumber, ' no existe.') AS  [Description]
		RETURN
	END

	IF NOT EXISTS(SELECT A1.Guide_Number			
		FROM DeliveryOrder A1 WITH (NOLOCK)
		INNER JOIN Customer A2 WITH (NOLOCK) 
			ON A1.IdCustomer = A2.IdCustomer
		WHERE A1.Ticket_Number = @TicketNumber
			AND ISNULL(A1.SenderCountryId, 'GT') = @IdCountry)
	BEGIN
		SELECT 1 AS [StatusCode] ,
				CONCAT('La referencia: ', @TicketNumber, ' pertenece a otro país') AS  [Description]
		RETURN
	END
END;