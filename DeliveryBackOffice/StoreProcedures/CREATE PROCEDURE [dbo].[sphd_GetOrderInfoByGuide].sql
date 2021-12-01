USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spg_get_RouteMonitor]    Script Date: 29/11/2021 11:11:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Alberto, Ixchop>
-- Create date: <2021-11-29>
-- Description:	<Devuelve todas las guias>
-- =============================================
--
ALTER PROCEDURE [dbo].[sphd_GetOrderInfoByGuide]
		@GuideToSearch as nvarchar(50)
AS
BEGIN
		
		SELECT  			 
			serv.Guide_Serie +  CAST(serv.Guide_Number AS VARCHAR) Guide, 
			serv.Guide_Serie GuideSerie,
			serv.Guide_Number GuideNumber,
			isnull(serv.Receiver_FirstName,'') + ' '+ isnull(serv.Receiver_LastName,'') Name,
			serv.Receiver_Address Address,
			serv.Receiver_Zone  Zone,
			serv.Receiver_Town Town,
			serv.Receiver_Department Department,
			serv.Delivery_Max_Date DeliveryMaxDate,
			serv.Courier_Route CourierRoute,
			(SELECT DeliveryBackOffice.dbo.fn_get_courier(serv.Guide_Serie, serv.Guide_Number)) CourierName,
			serv.DateCreated as DateCreated,
			isnull(serv.Sender_FirstName,'') + ' ' + isnull(serv.Sender_LastName,'') as SenderFullname,
			(serv.Pieces_Dry +serv.Pieces_Cold ) TotalPieces,
			(SELECT so.OrderDescription FROM StatusOrder so WHERE so.StatusOrderId = serv.StatusOrderId) as StatusName,
			StatusOrderId,
			serv.Receiver_Phone as ReceiverPhone,
			Talert.AlertTypeId as AlertId,
			Ttalert.AlertName  as AlertName,
			Talert.AlertDescription  as AlertDescription,
			serv.IsCollect,
			serv.PriceShippment,
			serv.TypeService,
			(SELECT p.Package_Name FROM Package p WHERE p.Package_Type = serv.Package_Type) as PackageType,
			(SELECT DeliveryBackOffice.dbo.fn_get_rackposition(serv.Guide_Serie, serv.Guide_Number)) as RackPosition
		FROM DeliveryBackOffice.DBO.DeliveryOrder serv
			LEFT JOIN DBO.DeliveryOrderAlert Talert ON Talert.GuideSerie=serv.Guide_Serie AND Talert.GuideNumber=serv.Guide_Number
			LEFT JOIN DBO.CatTypeAlert Ttalert ON Ttalert.IdCatTypeAlert= Talert.AlertTypeId 
		WHERE 
		Talert.RowStatus=1 OR Talert.RowStatus is NULL AND
		(serv.Guide_Serie +  CAST(Guide_Number AS VARCHAR) = @GuideToSearch)

		

END