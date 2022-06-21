-- =============================================
-- Author:		<Author,Edelman Vasquez>
-- Create date: <Create Date,2022-09-06>
-- Description:	<Description, Detalle de reporte general de reporte de cupones y promociones>
-- =============================================
CREATE PROCEDURE [dbo].[SPHD_CouponReportDetail]
	-- Add the parameters for the stored procedure here
	@DateOf   as DATE,
	@DateTo   as DATE
AS
BEGIN

	SET NOCOUNT ON;

    SELECT 
	      PC.GuideSerieOrigin  + Convert(Varchar,PC.GuideNumberOrigin) AS GuideOrigen,
	      PC.PromoCouponSerie,
		  PC.DateCreated,
		  C.Description as NameOrigin,
		  CP.PromoDescription,
		  PC.FinalActiveDate,
		  PC.GuideSerieDestination + Convert(Varchar,PC.GuideNumberDestination) As GuideDestination,
		  PC.RedeemedDate,
		  PC.DateUpdated,
		  C2.Description as NameDestination,
		  PC.OriginalAmount,
		  PC.DiscountAmount,
		  PC.FinalAmount,
		  CASE
	            WHEN  PC.RedeemedDate IS NOT  NULL             THEN  'CANJEADO'
				WHEN  PC.RedeemedDate IS NULL AND 
				      PC.DateCreated <= PC.FinalActiveDate AND 
					  GETDATE() <= PC.FinalActiveDate          THEN  'VALIDO'
                WHEN  PC.RowStatus=0                           THEN  'ANULADO'
	            WHEN  PC.FinalActiveDate < GETDATE()           THEN  'NO VIGENTE'
		   END STATUSCOUPON
	FROM 
		 [DeliveryBackOffice].[dbo].PromoCoupon PC WITH (NOLOCK)
    INNER JOIN
		 [DeliveryBackOffice].[dbo].CatPromo CP	   WITH (NOLOCK)
	ON   PC.CatPromoId = CP.IdPromo
	INNER JOIN 
		 [DeliveryBackOffice].[dbo].Customer C
	ON PC.CustomerOrigin = C.IdCustomer
	LEFT JOIN [DeliveryBackOffice].[dbo].Customer C2
	ON PC.CustomerDestination = C2.IdCustomer
	WHERE	
	     PC.DateCreated BETWEEN FORMAT(@DateOf, 'yyyy-MM-dd 00:00:00') 
		                    AND Format(@DateTo, 'yyyy-MM-dd 23:59:59')
	ORDER BY  STATUSCOUPON DESC 

END