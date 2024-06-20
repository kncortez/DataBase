-- =============================================
-- Author:		<Author,Edelman Vasquez>
-- Create date: <Create Date,2022-09-06>
-- Description:	<Description, Detalle de reporte general de reporte de cupones y promociones>
-- =============================================
-- =============================================
-- Author:		<Author,EDELMAN VASQUEZ>
-- Create date: <Create Date,2022-06-09>
-- Description:	<Description, MODIFICACIONES, AGREGAR COLUMNA DE EXC Y FILTRO, RESUMEN DE TOTALES DE GENERACIONES DE CUPONES Y DE CANJE>
-- =============================================
-- =============================================
-- Modified:	<Brandon Pedroza>
-- Create date: <2024-06-18>
-- Description:	<Se agrega parametro para filtra guias por pais de origen>
-- =============================================
CREATE PROCEDURE [dbo].[SPHD_CouponReportDetail]
	-- Add the parameters for the stored procedure here
	@DateOf		 as DATE,
	@DateTo		 as DATE,
	@IdStation   as INT,
	@IdCountry   as NVARCHAR(2) = 'GT'
	
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @CodeOfReference  as INT

	SELECT 
	      @CodeOfReference = CodeOfReference
	FROM DBO.CatStation
	WHERE IdStation = @IdStation

    SELECT 
	      VPC.DescriptionOfClient,
	      PC.GuideSerieOrigin  + Convert(Varchar,PC.GuideNumberOrigin) AS GuideOrigen,
		  DO.PriceShippment,
	      PC.PromoCouponSerie,
		  PC.DateCreated,
		  C.Description as NameOrigin,
		  CP.PromoDescription,
		  PC.FinalActiveDate,
		  PC.GuideSerieDestination + Convert(Varchar,PC.GuideNumberDestination) As GuideDestination,
		  PC.RedeemedDate,
		  PC.DateUpdated,
		  C2.Description as NameDestination,
		  ISNULL(PC.OriginalAmount,0) AS OriginalAmount,
		  ISNULL(PC.DiscountAmount,0) AS DiscountAmount,
		  ISNULL(PC.FinalAmount,0)    AS FinalAmount,
		  CASE
	            WHEN  PC.RedeemedDate IS NOT  NULL              THEN  'CANJEADO'
				WHEN  PC.RedeemedDate IS NULL AND 
				      PC.DateCreated <= PC.FinalActiveDate AND 
					  GETDATE() <= PC.FinalActiveDate  AND 
					  PC.RowStatus = 1                          THEN  'VALIDO'
	            WHEN  PC.FinalActiveDate < GETDATE()            THEN  'NO VIGENTE'
		   END STATUSCOUPON
	FROM 
		       [DeliveryBackOffice].[dbo].PromoCoupon PC          WITH (NOLOCK)	
    INNER JOIN
		       [DeliveryBackOffice].[dbo].CatPromo CP	          WITH (NOLOCK)
	ON   PC.CatPromoId = CP.IdPromo
	LEFT JOIN 
		       [DeliveryBackOffice].[dbo].Customer C              WITH (NOLOCK)
	ON PC.CustomerOrigin = C.IdCustomer
	LEFT JOIN  
	           [DeliveryBackOffice].[dbo].Customer C2			  WITH (NOLOCK)
	ON PC.CustomerDestination = C2.IdCustomer
	LEFT JOIN 
	           [DeliveryBackOffice].[dbo].[VisitPointClient] VPC  WITH (NOLOCK)
	ON PC.VisitPointClientOrigin = VPC.CodeOfReference
	LEFT JOIN 
	           [DeliveryBackOffice].[dbo].[DeliveryOrder] DO      WITH (NOLOCK)
	ON DO.Guide_Serie = PC.GuideSerieOrigin  AND 
	   DO.Guide_Number = PC.GuideNumberOrigin
	WHERE	
	     PC.DateCreated BETWEEN FORMAT(@DateOf, 'yyyy-MM-dd 00:00:00') 
		                    AND Format(@DateTo, 'yyyy-MM-dd 23:59:59')
							--AND PC.VisitPointClientOrigin = @CodeOfReference
							AND PC.RowStatus = 1
							AND ISNULL(DO.SenderCountryId, 'GT') = @IdCountry
	ORDER BY VPC.DescriptionOfClient, PC.DateCreated DESC 

END