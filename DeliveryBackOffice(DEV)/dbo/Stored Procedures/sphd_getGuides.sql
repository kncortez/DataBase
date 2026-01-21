
/* =================================================
   SP:        sphd_getGuides
   Propósito: Obtener información de las guías para mostrar al momento de actualizar los checkpoints
   Autor:     Cesar Sazo
   Historia:  ---
   Fecha:     2021-10-19

=== CHANGELOG ============================

2025-12-30 | Historia/épica: FDAPI-4759   | Autor: Brandon Pedroza |  Filtra guías por país

=========================================== */
CREATE PROCEDURE [dbo].[sphd_getGuides]
    @Guide_Serie VARCHAR(2),
    @Guide_Number INT,
	@IdCountry NVARCHAR(2) = 'GT'
AS
BEGIN
    IF EXISTS(SELECT 1 FROM  DeliveryBackOffice.dbo.DeliveryOrder AS do  WITH(NOLOCK)
					WHERE DO.Guide_Serie = @Guide_Serie
						AND DO.Guide_Number = @Guide_Number
						AND DO.SenderCountryId <> @IdCountry
				)
	BEGIN
		SELECT 402 AS [IdResult],
			'La guía no pertenece al país actual' AS [Message];
		RETURN
	END
    SELECT  200 AS [IdResult],
			Guide_Serie AS GuideSerie,
			Guide_Number AS GuideNumber, 
			Ticket_Number AS TicketNumber,
			Pieces_Dry+Pieces_Cold AS CountPieces, 
			c.[Name] AS Customer,
			Receiver_Address AS ReceiverAddress,
			so.OrderDescription  AS StatusDescription
    FROM DeliveryBackOffice.dbo.DeliveryOrder AS do WITH(NOLOCK)
    LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient AS vpc WITH(NOLOCK)
    ON do.Sender_ID = vpc.CodeOfReference
    LEFT JOIN DeliveryBackOffice.dbo.Customer AS c WITH(NOLOCK)
    on c.IdCustomer = ISNULL(do.IdCustomer, vpc.CustomerID)
    INNER JOIN DeliveryBackOffice.dbo.StatusOrder AS so WITH(NOLOCK)
    ON do.StatusOrderId = so.StatusOrderId
    WHERE Guide_Serie = @Guide_Serie
    AND Guide_Number = @Guide_Number

END