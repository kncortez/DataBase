-- =============================================  
-- Author:		<Brandon, Pedroza>  
-- Create date: <2025-01-13>  
-- Description: <Contenerizacion guias - Obtiene guias por numero de referencia>  
-- =============================================  

CREATE PROCEDURE [dbo].[sphwGetGuidesByTicketNumber]
    @TicketNumber NVARCHAR(50),
    @IdCountry NVARCHAR(5),
	@IdCustomer INT=0
AS
BEGIN
    SET NOCOUNT ON;
	DECLARE @IdStatusGenerated INT= (SELECT StatusOrderId FROM StatusOrder WITH(NOLOCK) WHERE OrderDescription = 'Solicitado');
	DECLARE @IdStatusRequest INT= (SELECT StatusOrderId FROM StatusOrder WITH(NOLOCK) WHERE OrderDescription = 'Generado');

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
		  AND A1.StatusOrderId IN (@IdStatusGenerated,@IdStatusRequest)
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
		  AND A1.StatusOrderId IN (@IdStatusGenerated,@IdStatusRequest)
	END
END;
