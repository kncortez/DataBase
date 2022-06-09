
-- =============================================
-- Author:		Carlos Cano
-- Create date: 31/05/2020
-- Description:	devuelve el listado de comprobantes de guías electrónicas
-- =============================================
-- =============================================
-- Author:		López, Marcos
-- Create date: 21/09/2020
-- Description:	Se agregó el costo de cobro en las entregas
-- =============================================
CREATE PROCEDURE [dbo].[spg_deliveryorders_by_number]
	@_serie nvarchar(2) = 'FD'
	,@_number nvarchar(max)  --parametro
AS
BEGIN
	SET NOCOUNT ON;

    select
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
	,case when do.IsCollect = 'TRUE' then 
	CONVERT(VARCHAR, CAST((isnull(do.Collect_OnDelivery,0) + isnull(do.PriceShippment,0)) AS MONEY), 1) 
	else 
	CONVERT(VARCHAR, CAST((isnull(do.Collect_OnDelivery,0)) AS MONEY), 1) 
	end AS  Collect_OnDelivery
	,do.Contact_Confirmed
	,do.Contact_Instructions
	,isnull(do.Receiver_CUI,' ') as Receiver_CUI
	from [DeliveryBackOffice].[dbo].DeliveryOrder do with(nolock)
	where 
	do.Guide_Serie = @_serie
	and do.Guide_Number IN (SELECT Item FROM DenariusDesktop_Dev.dbo.SplitUnlimited(@_number,','))
	and do.Guide_Number is not NULL
    and CAST(IIF(do.IsCollect = 'TRUE', isnull(do.PriceShippment,0), 0) AS MONEY) <= 0
	and CAST(isnull(do.Collect_OnDelivery,0) AS MONEY) <= 0
	order by do.Guide_Number asc
END
