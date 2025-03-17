-- =============================================
-- Author:		<Brandon, Pedroza>
-- Create date: <024-12-10>
-- Description:	<Liquidacion Rutas Express - Se obtienen guias por numero de ticket>
-- =============================================
CREATE PROCEDURE [dbo].[sphwGetGuidesByTicketNumber]
    @TicketNumber NVARCHAR(50),
    @IdCountry NVARCHAR(5)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        ISNULL(A1.Ticket_Number, '') AS TicketNumber,
        ISNULL(A2.[Name], A2.[Description]) AS Customer,
        A1.Guide_Number AS GuideNumber,
        A1.Guide_Serie AS GuideSerie, 
        (A1.Pieces_Cold + A1.Pieces_Dry) AS GuidePieces
    FROM DeliveryBackOffice.dbo.DeliveryOrder A1 WITH (NOLOCK)
    INNER JOIN DeliveryBackOffice.dbo.Customer A2 WITH (NOLOCK) 
        ON A1.IdCustomer = A2.IdCustomer
    WHERE A1.Ticket_Number = @TicketNumber
      AND A1.SenderCountryId = @IdCountry;
END;

