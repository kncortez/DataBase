/* =================================================
   SP:        [dbo].[sphdGetVisitPointbyCustomerID]
   Propósito: Get All VisitPoint by CustomerID
   Autor:     Edwin Ramirez
   Historia:  <>
   Fecha:     2021-04-29

=== CHANGELOG ============================
2026-05-20 | Historia/épica: FDAPI-6153           | Autor: Mario Herrarte         | Retornar bandera de punto de visita para devoluciones.
=========================================== */
CREATE PROCEDURE [dbo].[sphdGetVisitPointbyCustomerID]
	-- Add the parameters for the stored procedure here
	@IdCustomer as int ,
	@Option int = 0,
	@IdVisitPoint AS INT = -1
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	if (@Option = 0 ) 
	begin 
		-- Insert statements for procedure here
		select  
			[IdVisitPointClient],
			[CodeOfReference],
			[DescriptionOfClient],
			vpc.Address,
			vpc.Town,
			vpc.Department,
			[CustomerID],
			IIF(vpc.ExcludePriceShippingCOD = 'TRUE', vpc.ExcludePriceShippingCOD, 'FALSE') CODExcludedPriceShipping,
			IIF(vpc.ExcludeCommissionCOD = 'TRUE', vpc.ExcludeCommissionCOD, 'FALSE') CODExcludedCommission,
			vpc.StatusClient,
			ISNULL(vpc.AllowScheduledPickups, 1) 'AllowScheduledPickups',
			vpc.isReturnWarehouse
		from DeliveryBackOffice.dbo.VisitPointClient vpc
		where vpc.CustomerID = @IdCustomer
		--and vpc.StatusClient = 'TRUE'
	end 
	if (@Option = 1 ) 
	begin 

		select  
			--[IdVisitPointClient]												 [IdValue],
			[CodeOfReference]													 [IdValue],
			IIF(vpc.StatusClient = 0, '[INACTIVO] ', '') + Cast([CodeOfReference] as varchar) + ' ' +  [DescriptionOfClient]   [NameValue]  ,
			[CustomerID]														 [IdFilter],
			IIF(vpc.ExcludePriceShippingCOD = 'TRUE', vpc.ExcludePriceShippingCOD, 'FALSE') CODExcludedPriceShipping,
			IIF(vpc.ExcludeCommissionCOD = 'TRUE', vpc.ExcludeCommissionCOD, 'FALSE') CODExcludedCommission,
			ISNULL(vpc.AllowScheduledPickups, 1) 'AllowScheduledPickups',
			vpc.isReturnWarehouse
		from DeliveryBackOffice.dbo.VisitPointClient vpc
		where (@IdCustomer = -1 or vpc.CustomerID = @IdCustomer)
		and (@IdVisitPoint = -1 OR vpc.CodeOfReference = @IdVisitPoint)
		--and vpc.StatusClient = 'TRUE'
		ORDER BY NameValue  

	end 

END
