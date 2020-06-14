USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[spg_ddeli_deliveryOrders]    Script Date: 3/06/2020 16:56:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Emilio Orozco
-- Create date: 11/05/2020
-- Description:	devuelve el listado de comprobantes de entrega para el igss
-- =============================================


CREATE PROCEDURE [dbo].[spg_ddeli_deliveryOrders]
	@_serie nvarchar(2)
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
	--SUBSTRING('12345678901234567890', 1, 10) as Ticket_Number
	,(do.pieces_Dry + do.Pieces_Cold) as Pieces
	,do.Receiver_FirstName + ' ' + do.Receiver_LastName as receiver_name
	--,'123456789.1234567890.1234567890.1234567890.1234567890.1234567890.1234567890.1234567890.1234567890' AS Receiver_Address
	,do.Receiver_Address AS Receiver_Address
	,do.Receiver_Phone
	,do.Sender_FirstName + ' ' + do.Sender_LastName as sender_name
	--,SUBSTRING('123456789.1234567890.1234567890.1234567890.1234567890.1234567890.1234567890.1234567890.1234567890', 1, 74) as sender_name
	--,'123456789.1234567890.1234567890.1234567890.1234567890.1234567890.1234567890.1234567890.1234567890' AS sender_name
	,do.Sender_Address + ', Zona ' + do.Sender_Zone + ' ' + do.Sender_Town + ', ' + do.Sender_Department as sender_address
	,'Tel. ' + do.Sender_Phone as sender_phone
	,do.Guide_Serie + isnull(convert(nvarchar,do.Guide_Number),'') as Guide
	,'<B>Fecha de Preparación:</B>' + CONVERT(varchar, do.Preparation_Date, 103) + ' ' + CONVERT(varchar(5), do.Preparation_Date, 108) as preparation_date
	,'<BR/><B>Fecha de Envío:</B>' + CONVERT(varchar, do.Shipping_Date, 103) as shipping_date
	,'<BR/><B>Fecha Máxima Entrega:</B>' + isnull(CONVERT(varchar, do.Delivery_Max_Date, 103),'') as max_date
	,do.Guide_Number
	from [DeliveryBackOffice].[dbo].DeliveryOrder do with(nolock)
	where ( (@type = 1 and do.Manifest_Serie = @serie and do.Manifest_Number = @number)
	or (@type = 2 and do.Guide_Serie = @serie and do.Guide_Number = @number))
	and do.Guide_Number is not null
	order by do.Guide_Number asc
END
GO


