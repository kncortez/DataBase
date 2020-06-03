USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[spg_deliveryorders_by_number]    Script Date: 3/06/2020 16:57:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Carlos Cano
-- Create date: 31/05/2020
-- Description:	devuelve el listado de comprobantes de guías electrónicas
-- =============================================


CREATE PROCEDURE [dbo].[spg_deliveryorders_by_number]
	@_serie nvarchar(2) = 'FD'
	,@_number nvarchar(max)
AS
BEGIN
	SET NOCOUNT ON;

    select
	do.Ticket_Number
	,(do.pieces_Dry + do.Pieces_Cold) as Pieces
	,do.Receiver_FirstName + ' ' + do.Receiver_LastName as receiver_name
	,do.Receiver_Address AS Receiver_Address
	,do.Receiver_Phone
	,do.Sender_FirstName + ' ' + do.Sender_LastName as sender_name
	,do.Sender_Address + ', Zona ' + do.Sender_Zone + ' ' + do.Sender_Town + ', ' + do.Sender_Department as sender_address
	,'Tel. ' + do.Sender_Phone as sender_phone
	,do.Guide_Serie + isnull(convert(nvarchar,do.Guide_Number),'') as Guide
	,'<B>Fecha de Preparación:</B>' + CONVERT(varchar, do.Preparation_Date, 103) + ' ' + CONVERT(varchar(5), do.Preparation_Date, 108) as preparation_date
	,'<BR/><B>Fecha de Envío:</B>' + CONVERT(varchar, do.Shipping_Date, 103) as shipping_date
	,'<BR/><B>Fecha Máxima Entrega:</B>' + isnull(CONVERT(varchar, do.Delivery_Max_Date, 103),'') as max_date
	,do.Guide_Number as Guide_Number
	,do.Courier_Route as Courier_Route
	,CONVERT(varchar, do.Dispatched_Date, 103) as Dispatched_Date
	,do.Courier_Name as Courier_Name
	from [DeliveryBackOffice].[dbo].DeliveryOrder do with(nolock)
	where 
	do.Guide_Serie = @_serie
	and do.Guide_Number IN (SELECT Item FROM DenariusDesktop_Dev.dbo.SplitUnlimited(@_number,','))
	and do.Guide_Number is not null
	order by do.Guide_Number asc
END
GO


