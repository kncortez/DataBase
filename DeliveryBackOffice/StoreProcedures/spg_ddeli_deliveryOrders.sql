USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[spg_ddeli_deliveryOrders]    Script Date: 30/12/2020 12:46:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Emilio Orozco
-- Create date: 11/05/2020
-- Description:	devuelve el listado de comprobantes de entrega para el igss
-- =============================================


ALTER PROCEDURE [dbo].[spg_ddeli_deliveryOrders]
	@_serie nvarchar(2) --
	,@_number int
	,@_type tinyint --1 por manifiesto, 2 por orden
AS
BEGIN
	SET NOCOUNT ON;

	declare @serie nvarchar(2) = @_serie
	,@number int = @_number
	,@type tinyint = @_type

    select distinct  
	do.Ticket_Number
	,(do.pieces_Dry + do.Pieces_Cold) as Pieces
	,isnull(do.Receiver_FirstName,'') + ' ' + isnull(do.Receiver_LastName,'') as receiver_name
	,do.Receiver_Address AS Receiver_Address
	,do.Receiver_Phone
	,do.Sender_FirstName + ' ' + do.Sender_LastName as sender_name
	,do.Sender_Address + ', Zona ' + do.Sender_Zone + ' ' + do.Sender_Town + ', ' + do.Sender_Department as sender_address
	,'Tel. ' + do.Sender_Phone as sender_phone
	,do.Guide_Serie + isnull(convert(nvarchar,do.Guide_Number),'') as Guide
	,'<BR/><B>Fecha de Preparación:</B> ' + CONVERT(varchar, do.Preparation_Date, 103) + ' ' + CONVERT(varchar(5), do.Preparation_Date, 108) as preparation_date
	,'<BR/><B>Fecha de Envío:</B> ' + CONVERT(varchar, do.Shipping_Date, 103) as shipping_date
	,'<BR/><B>Fecha Máxima Entrega:</B> ' + isnull(CONVERT(varchar, do.Delivery_Max_Date, 103),'') as max_date
	,do.Guide_Number as Guide_Number
	,do.Courier_Route as Courier_Route
	,CONVERT(varchar, do.Dispatched_Date, 103) as Dispatched_Date
	,do.Courier_Name as Courier_Name
	,do.Package_Description as Package_Description
	,do.Sender_ID as Sender_ID
	,do.Recipe_Number as Recipe_Number
	,'<B>Manifiesto:</B> ' + do.Manifest_Serie + convert(nvarchar, do.Manifest_Number) as Manifest
	,CONVERT(VARCHAR, CAST(do.Collect_OnDelivery AS MONEY), 1) AS  Collect_OnDelivery
	,do.Contact_Confirmed
	,do.Contact_Instructions
	from [DeliveryBackOffice].[dbo].DeliveryOrder do with(nolock)
	where ( (@type = 1 and do.Manifest_Serie = @serie and do.Manifest_Number = @number)
	or (@type = 2 and do.Guide_Serie = @serie and do.Guide_Number = @number))
	and do.Guide_Number is not null
	order by do.Guide_Number asc
END
GO


