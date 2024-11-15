-- =============================================
-- Author:		<Oscar Rodriguez>
-- Create date: <2024-11-14>
-- Description:	<Obtencion de guias a notificar por servicio Hermes Webhook Sender>
-- =============================================
CREATE PROCEDURE [dbo].[sphwGetStatusNotifications]
	--@IdCountry NVARCHAR(2)= 'GT'
AS
BEGIN
	SELECT TOP(1000) 
		gsn.NirPhoner [Nirphone],
		gsn.Phone [Phone],
		gsn.GuideSerie [GuideSerie],
		gsn.GuideNumber [GuideNumber],
		so.OrderDescription [StatusDescription],
		dod.DateCreated [StatusDateCreated]
	FROM DeliveryBackOffice.dbo.GuideStatusNotification gsn
	INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do 
		ON gsn.GuideSerie = do.Guide_Serie AND gsn.GuideNumber = do.Guide_Number
	INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderDetail dod 
		ON dod.Guide_Serie = do.Guide_Serie AND dod.Guide_Number = do.Guide_Number
	LEFT JOIN DeliveryBackOffice.dbo.StatusOrder so 
		ON so.StatusOrderId = dod.StatusOrderId
	WHERE so.CATStatusTypeId = 2
	AND gsn.LastChangeDate < dod.DateCreated
	AND so.RowStatus = 1
	AND gsn.RowStatus = 1
	AND gsn.FinalStatus = 0
	--AND gsn.CountryId = @IdCountry
END;
