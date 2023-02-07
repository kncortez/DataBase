

-- =============================================
-- Author:		<Alberto, Ixchop>
-- Create date: <2021-11-29>
-- Description:	<Devuelve todas las guias con informacion de sus posibles alertas que posee>
-- =============================================
--
CREATE PROCEDURE [dbo].[sphd_GetOrderInfoByGuide]
		@GuideToSearch as nvarchar(50)
AS
BEGIN
		SELECT  			
			serv.Guide_Serie +  CAST(serv.Guide_Number AS VARCHAR) Guide, 
			serv.Guide_Serie GuideSerie,
			serv.Guide_Number GuideNumber,
			isnull(serv.Sender_FirstName,'') + ' '+ isnull(serv.Sender_LastName,'') Sender,
			serv.Sender_Address SenderAddress,
			serv.Sender_Phone SenderPhone,
			serv.IndicationsToSendOrigin SenderIndications,
			isnull(serv.Receiver_FirstName,'') + ' '+ isnull(serv.Receiver_LastName,'') Receiver,
			serv.Receiver_Address ReceiverAddress,
			serv.Receiver_Phone ReceiverPhone,
			serv.IndicationsToSendDestination ReceiverIndications,
			serv.IsCollect,			
			Talert.IdDeliveryOrderAlert AlertId,
			Talert.AlertDescription	AlertDescription,
			Talert.DateCreated AlertCreated,
			Talert.AlertTypeId AlertTypeId,
			Talert.ServiceTypeId AlertServiceTypeId,			
			serv.StatusOrderId StatusId,
			SO.OrderDescription StatusDescription,
			serv.Sender_Department	SenderDepartment,
			serv.Sender_Town	SenderTown, 
			serv.SenderIdTownship SenderIdtownship,
			Receiver_Department ReceiverDepartment,
			Receiver_Town ReceiverTown,
			ReceiverIdSettlement,
			CASE WHEN SO.OrderDescription not in (
                'Entregado',
                'Anulado',
                'Devuelto',
                'Entregado En Express Center',
                'Devuelto en Express Center',
                'COD liquidado',
                'COD pagado'
			) then 1 else 0 end AllowCreateAlert
		FROM DeliveryBackOffice.DBO.DeliveryOrder serv WITH(NOLOCK)
			LEFT JOIN DBO.StatusOrder SO WITH(NOLOCK) ON serv.StatusOrderId=SO.StatusOrderId 
		    LEFT JOIN DBO.FinalStatusByModule FSBM  WITH(NOLOCK) ON FSBM.StatusOrderId=SERV.StatusOrderId
			LEFT JOIN DBO.DeliveryOrderAlert Talert WITH(NOLOCK) ON Talert.GuideSerie=serv.Guide_Serie AND Talert.GuideNumber=serv.Guide_Number AND Talert.RowStatus=1 
					AND FSBM.IdFinalStatusByModule IS  NULL			
			LEFT JOIN DBO.CatTypeAlert Ttalert WITH(NOLOCK) ON Ttalert.IdCatTypeAlert= Talert.AlertTypeId  
			
		WHERE 
		(serv.Guide_Serie +  CAST(Guide_Number AS VARCHAR) = @GuideToSearch)
		

END
