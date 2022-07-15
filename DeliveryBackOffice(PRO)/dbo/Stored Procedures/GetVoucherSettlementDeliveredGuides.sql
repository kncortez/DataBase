-- =============================================
-- Author:		<Oscar, Morales>
-- Create date: <2022-07-06>
-- Description:	<Recupera detalle para generar manifiesto de comprobantes de entregas>
-- =============================================
CREATE PROCEDURE [dbo].[GetVoucherSettlementDeliveredGuides]
	-- Add the parameters for the stored procedure here
	@IdManifest INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		CONCAT(do.Guide_Serie, do.Guide_Number) Guide
	   ,CONCAT(do.Receiver_FirstName, IIF(do.Receiver_FirstName IS NULL, '', IIF(do.Receiver_LastName IS NULL, '', ' ')), do.Receiver_LastName) ReceiverName
	   ,do.Receiver_Address ReceiverAddress
	FROM DeliverySettlementDetail dsd
	INNER JOIN DeliveryOrder do
		ON do.Guide_Serie = dsd.Guide_Serie
			AND do.Guide_Number = dsd.Guide_Number
	WHERE dsd.ID_DeliveryOrderBySettlement = @IdManifest
	AND do.IsCollect = 0
	AND NOT do.Collect_OnDelivery > 0
	ORDER BY do.Guide_Number
END