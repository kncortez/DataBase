

-- =============================================
-- Author:		<Alberto, Ixchop>
-- Create date: <2021-11-29>
-- Description:	<Devuelve todas las guias con informacion de sus posibles alertas que posee>
-- =============================================
-- Modified:	<Brandon, Pedroza>
-- Create date: <2024-06-27>
-- Description:	<Se agrega parametro para filtrar por pais >
-- =============================================
CREATE PROCEDURE [dbo].[sphd_GetOrderInfoByGuide]
		@GuideToSearch as nvarchar(50),
		@IdCountry AS NVARCHAR(2) = 'GT'
AS
BEGIN
	DECLARE @GuideSerie nvarchar(2);
    DECLARE @GuideNumber int;

    SET @GuideSerie = SUBSTRING(@GuideToSearch, 1, 2); 
    SET @GuideNumber = CAST(SUBSTRING(@GuideToSearch, 3, LEN(@GuideToSearch) - 2) AS int); 
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
		serv.Guide_Serie = @GuideSerie AND serv.Guide_Number = @GuideNumber
		AND (ISNULL(serv.GuideType,'DOM')='INT' OR (ISNULL(serv.SenderCountryId,'GT')=@IdCountry AND ISNULL(serv.GuideType,'DOM')='DOM'))
		
		---TABLA RESPUESTA
		SELECT 'La guía que intentas procesar pertenece a otro pais. Por favor, revísala e intenta de nuevo.' AS [Description]
		FROM DeliveryOrder do WITH (NOLOCK)
		WHERE do.Guide_Serie = @GuideSerie and do.Guide_Number=@GuideNumber
		AND 		
		ISNULL(do.SenderCountryId,'GT')<>@IdCountry AND ISNULL(do.GuideType,'DOM')='DOM'

END