-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Carlos,Cano>
-- Create date: <13/06/2020>
-- Description:	<Detalle de rastreo en pagina web tracking para el cliente>
-- =============================================
ALTER PROCEDURE spg_status_order_detail_web
	@Guide_Serie NVARCHAR(2),
	@Guide_Number INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT
		do.Guide_Serie + CAST(do.Guide_Number AS VARCHAR) as OrderId, -- guide
		do.Receiver_FirstName + ' ' + do.Receiver_LastName as CustomerFullname, -- receiver fullname
		do.Sender_Address as OriginAdress, -- sender address
		'' as OriginLatitude,
		'' as OriginLongitude,
		do.Receiver_Address as DestinyAddress, -- receiver address
		'' as DestintyLatitude,
		'' as DestinyLongitude,
		do.Courier_Name as CourierName
	FROM DeliveryBackOffice.dbo.DeliveryOrder do
	WHERE do.Guide_Serie = @Guide_Serie AND do.Guide_Number = @Guide_Number

	SELECT
		dod.StatusOrderId as 'EventID', -- status order id
		dod.DateCreated as 'Date', -- date of status id
		so.OrderDescription as 'Title' -- status order name
	FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod 
	JOIN DeliveryBackOffice.dbo.StatusOrder so on so.StatusOrderId = dod.StatusOrderId
	WHERE dod.Guide_Serie = @Guide_Serie and dod.Guide_Number = @Guide_Number
	ORDER BY dod.DateCreated ASC
	
END
GO
