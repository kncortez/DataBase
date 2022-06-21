
-- =============================================
-- Author:		Emilio Orozco
-- Create date: 11/05/2020
-- Description:	devuelve el listado de comprobantes de entrega para el igss
-- =============================================
-- =============================================
-- Author:		Oscar Morales
-- Create date: 07/06/2022
-- Description:	Versión Especial para guías del IGGS y RENAP
-- =============================================
CREATE PROCEDURE [dbo].[spg_ddeli_deliveryOrders_esp]
	@_serie nvarchar(2)
	,@_number int
	,@_type tinyint --1 por manifiesto, 2 por orden.
AS
BEGIN
	SET NOCOUNT ON;

	declare @serie nvarchar(2) = @_serie
	,@number int = @_number
	,@type tinyint = @_type

    select distinct  
		do.Ticket_Number
	   ,(do.pieces_Dry + do.Pieces_Cold) Pieces
	   ,ISNULL(do.Receiver_FirstName, '') + ' ' + ISNULL(do.Receiver_LastName, '') receiver_name
	   ,ISNULL(do.Receiver_Alternant_FullName, '') receiver_name_alternant
	   ,do.Receiver_Address +
		CASE
			WHEN ISNULL(do.Receiver_Town, '') <> '' THEN ', ' + ISNULL(do.Receiver_Town, '')
			ELSE ISNULL(do.Receiver_Town, '')
		END +
		CASE
			WHEN ISNULL(do.Receiver_Department, '') <> '' THEN ', ' + ISNULL(do.Receiver_Department, '')
			ELSE ISNULL(do.Receiver_Department, '')
		END Receiver_Address
	   ,do.Receiver_Phone
	   ,do.Sender_FirstName + ' ' + do.Sender_LastName sender_name
	   ,do.Sender_Address + ', Zona ' + do.Sender_Zone + ' ' + do.Sender_Town + ', ' + do.Sender_Department sender_address
	   ,'Tel. ' + do.Sender_Phone sender_phone
	   ,do.Guide_Serie + ISNULL(CONVERT(NVARCHAR, do.Guide_Number), '') Guide
	   ,'<BR/><B>Fecha de Preparación:</B> ' + CONVERT(VARCHAR, do.Preparation_Date, 103) + ' ' + CONVERT(VARCHAR(5), do.Preparation_Date, 108) preparation_date
	   ,'<BR/><B>Fecha de Envío:</B> ' + CONVERT(VARCHAR, do.Shipping_Date, 103) shipping_date
	   ,'<BR/><B>Fecha Máxima Entrega:</B> ' + ISNULL(CONVERT(VARCHAR, do.Delivery_Max_Date, 103), '') max_date
	   ,do.Guide_Number Guide_Number
	   ,do.Courier_Route Courier_Route
	   ,CONVERT(VARCHAR, do.Dispatched_Date, 103) Dispatched_Date
	   ,do.Courier_Name Courier_Name
	   ,do.Package_Description Package_Description
	   ,do.Sender_ID Sender_ID
	   ,do.Recipe_Number Recipe_Number
	   ,'<B>Manifiesto:</B> ' + do.Manifest_Serie + CONVERT(NVARCHAR, do.Manifest_Number) Manifest
	   ,do.IsCollect
	   ,do.Contact_Confirmed
	   ,do.Contact_Instructions
	   ,ISNULL(do.Receiver_CUI, '') Receiver_CUI
	   ,ISNULL(do.Receiver_Alternant_CUI, '') Receiver_Alternant_CUI
	from [DeliveryBackOffice].[dbo].DeliveryOrder do with(nolock)
	where ( (@type = 1 and do.Manifest_Serie = @serie and do.Manifest_Number = @number)
	or (@type = 2 and do.Guide_Serie = @serie and do.Guide_Number = @number))
	and do.Guide_Number is not null
	order by do.Guide_Number asc
END