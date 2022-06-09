-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <2020-08-05>
-- Description:	<Devuelve la opcion y precio shipping>
-- =============================================
CREATE PROCEDURE [dbo].[spws_get_customer_depot]	
		    @CodApp as nvarchar(50) = 'SILVBECOM120820200901',
			@IdSeller varchar(100)  = '', --Seller
			@IdSource as bigint = 0, --Settlement
			@CodeOfReference as varchar(100) = '', --Id Depot
			@IdSellerDepot as int = 0 --Id Depot Forza
AS
BEGIN		
select
		--se identifica el Ecommerce en base al CodeApp enviado 
		Sld.[IdSellerDepot] as IdWarehouse, 
		Sld.[CodeOfReference] as IdSeller, 
		Sld.[IdSettlement], 
		Sld.[CodeOfReference], 
		Sld.[DescriptionOfClient], 
		Sld.[Address], 
		Sld.[Phone], 
		Sld.[ContactName], 
		Sld.[Status], 
		Sld.[DateCreated], 
		Sld.[DateUpdated]			
		--into #Ecommrce
		from DeliveryBackOffice.[dbo].[Ecommerce] eco 
		join DeliveryBackOffice.dbo.Customer Cst on eco.IdCustomer = Cst.IdCustomer
		join DeliveryBackOffice.dbo.Seller Sll on Cst.IdCustomer = Sll.IdCustomer
			and (@IdSeller ='' or Sll.CodeOfReference = @IdSeller)
		join DeliveryBackOffice.[dbo].[SellerDepot] Sld on 
		    (Sld.IdSeller = Sll.IdSeller)		
			and ( @IdSource=0 or Sld.IdSettlement = @IdSource )
			and (@CodeOfReference ='' or Sld.CodeOfReference = @CodeOfReference) 
			and (@IdSellerDepot = 0 or Sld.IdSellerDepot = @IdSellerDepot)
		join DeliveryBackOffice.dbo.Settlement Stt on
		( @IdSource = 0 or @IdSource = Stt.IdSettlement)		
		and Stt.IdSettlement = Sld.IdSettlement				
		where eco.UserKey = @CodApp 
		and eco.EcommerceStatus = 'TRUE'

END