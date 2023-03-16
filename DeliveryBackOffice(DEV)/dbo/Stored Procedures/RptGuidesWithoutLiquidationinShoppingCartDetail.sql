-- =============================================
-- Author:		<Author,Edelman Vásquez>
-- Create date: <Create Date,2023-03-03>
-- Description:	<Description, SP para cabecera de reporte de guías en carrito de compra que no estan liquidadas y no son collect>
-- =============================================
CREATE PROCEDURE [dbo].[RptGuidesWithoutLiquidationinShoppingCartDetail] 
@IdConflictManifest int		
AS
BEGIN

     
	 DECLARE @temp TABLE (
		Guide_Code	nvarchar(max),
		Sender_Fullname nvarchar(201),
		Sender_Phone nvarchar(100),
		Sender_Address nvarchar(600),
	    TotalPrice  Decimal(18,2)
	                      )

	SET NOCOUNT ON;

	-- tablix content
	INSERT INTO @temp
							SELECT
								   CMD.GuideSerie + Cast(CMD.GuideNumber as nvarchar(20))
								  ,DO.Sender_FirstName +' '+ DO.Sender_LastName	
								  ,DO.Sender_Phone
								  ,DO.Sender_Address
								  ,CMD.GuidePrice
							FROM [dbo].[ConflictManifestDetail] CMD
							INNER JOIN [dbo].[DeliveryOrder] DO	
							ON CMD.GuideSerie = DO.Guide_Serie And DO.Guide_Number = CMD.GuideNumber 
								   

    SELECT Guide_Code,
	       Sender_Fullname,
		   Sender_Phone,
		   Sender_Address,
		   TotalPrice
	FROM @temp
	Order By Guide_Code Desc
END