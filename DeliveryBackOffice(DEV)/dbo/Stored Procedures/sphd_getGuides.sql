
-- =============================================
-- Author:      <Sazo,Cesar>
-- Create date: <2021-10-19>
-- Description: <Obtener informacion de las guias para mostrar al momento de actualizar los checkpoints>
-- =============================================
-- Author:		<Pedroza, Ochoa>  
-- Modified:	<2025-05-06>  
-- Description:	<Contenerizacion - Obtiene la referencia de guia en modulo de administrador de estados>
-- =============================================
-- Author:		<Pedroza, Ochoa>  
-- Modified:	<2025-05-06>  
-- Description:	<Multipais - Filtra guias por pais>
-- ============================================= 
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
			'La guía/referencia  pertenece a otro país' AS [Message];
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
    FROM DeliveryBackOffice.dbo.DeliveryOrder AS do
    LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient AS vpc
    ON do.Sender_ID = vpc.CodeOfReference
    LEFT JOIN DeliveryBackOffice.dbo.Customer AS c
    on c.IdCustomer = ISNULL(do.IdCustomer, vpc.CustomerID)
    INNER JOIN DeliveryBackOffice.dbo.StatusOrder AS so
    ON do.StatusOrderId = so.StatusOrderId
    WHERE Guide_Serie = @Guide_Serie
    AND Guide_Number = @Guide_Number
	AND do.SenderCountryId = @IdCountry

END