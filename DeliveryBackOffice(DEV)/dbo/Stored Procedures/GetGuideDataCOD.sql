-- =============================================
-- Author:		<Bidcar Herrera>
-- Create date: <2021-08-10>
-- Description:	<Obtener el COD de una guía>
-- =============================================
-- =============================================
-- Modification:<Marco Jiménez>
-- Create date: <2021-11-08>
-- Description:	<Se agrega columnas y se agrega 
--              filtro de estados para no aceptar 
--              cambios en guías ya entregadas>
-- =============================================
CREATE PROCEDURE [dbo].[GetGuideDataCOD]
    @GuideSerie NVARCHAR(50),
	@GuideNumber NVARCHAR(50)
AS
BEGIN

SELECT DOR.Guide_Serie + CAST(DOR.Guide_Number AS VARCHAR(50)) Guide,
       CONCAT(DOR.Sender_FirstName, ' ', DOR.Sender_LastName) SenderName,
       ISNULL(CONCAT(DOR.Receiver_FirstName, ' ', DOR.Receiver_LastName), '') ReceiverName,
       DOR.PriceShippment AS Envio,
       CONVERT(VARCHAR, CONVERT(VARCHAR, CAST(DOR.Collect_OnDelivery AS MONEY), 1)) Collect_OnDelivery
FROM DeliveryBackOffice.dbo.DeliveryOrder DOR
    INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderDetail DORD
        ON DOR.Guide_Serie = DORD.Guide_Serie
           AND DOR.Guide_Number = DORD.Guide_Number
WHERE DOR.Guide_Serie = @GuideSerie
      AND DOR.Guide_Number = @GuideNumber
      AND NOT EXISTS
(
    SELECT StatusOrderId
    FROM DeliveryOrderDetail
    WHERE StatusOrderId IN ( 5, 22 )
          AND Guide_Serie = DORD.Guide_Serie
          AND Guide_Number = DORD.Guide_Number
) --(Entregado,Entregado En Express Center)
GROUP BY DOR.Guide_Serie,
         DOR.Guide_Number,
         DOR.Sender_FirstName,
         DOR.Sender_LastName,
         DOR.Receiver_FirstName,
         DOR.Receiver_LastName,
         DOR.PriceShippment,
         DOR.Collect_OnDelivery

END
