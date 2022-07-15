-- =============================================
-- Author:		<Oscar, Morales>
-- Create date: <2022-07-06>
-- Description:	<Recupera información para generar manifiesto de comprobantes de entregas>
-- =============================================
CREATE PROCEDURE [dbo].[GetVoucherSettlementDelivered]
	-- Add the parameters for the stored procedure here
	@IdManifest INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		dobs.ID Id
	   ,dobs.Date_Received DateReceived
	   ,CONCAT(sr.First_Name, IIF(sr.First_Name IS NULL, '', IIF(sr.Last_Name IS NULL, '', ' ')), sr.Last_Name) CourierName
	   ,lbt.SSN_Username UserNameReceived
	FROM DeliveryOrderBySettlement dobs
	INNER JOIN SenderReceiver sr
		ON sr.ID = dobs.ID_Courier
	LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken lbt
		ON lbt.SSN_IdToken = dobs.User_Received
	WHERE dobs.ID = @IdManifest
END