-- =============================================
-- Author:		Bidcar Herrera
-- Description:	Retorna de guías de posible estafa para el área de Gestión Administrativa
-- =============================================
CREATE PROCEDURE [dbo].[spg_reportOnPotentialScamGuides]
AS
BEGIN
SELECT ord.DateCreated [Fecha]
     , ord.Guide_Serie [Serie]
     , ord.Guide_Number [Número]
	 , ord.Sender_Address [Dirección origen]
     , st.OrderDescription [Estado]
FROM dbo.DeliveryOrder         ord WITH (NOLOCK)
    INNER JOIN dbo.StatusOrder st
        ON st.StatusOrderId = ord.StatusOrderId
WHERE CONVERT(DATE, ord.DateCreated) = CONVERT(DATE, GETDATE())
AND Sender_Address LIKE '%37%1%63%'
	
END