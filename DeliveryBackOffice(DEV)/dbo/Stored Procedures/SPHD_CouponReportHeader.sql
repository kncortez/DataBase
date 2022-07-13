-- =============================================
-- Author:		<Author,EDELMAN VASQUEZ>
-- Create date: <Create Date,2022-06-09>
-- Description:	<Description, REPORTE GENERAL DE CUPONES Y PROMOCIONES>
-- =============================================
-- =============================================
-- Author:		<Author,EDELMAN VASQUEZ>
-- Create date: <Create Date,2022-06-09>
-- Description:	<Description, MODIFICACIONES, AGREGAR COLUMNA DE EXC Y FILTRO, RESUMEN DE TOTALES DE GENERACIONES DE CUPONES Y DE CANJE>
-- =============================================
CREATE PROCEDURE [dbo].[SPHD_CouponReportHeader] 
	-- Add the parameters for the stored procedure here
	@DateOf       as DATE,
	@DateTo       as DATE,
	@IdStation    as INT
AS
BEGIN

	SET NOCOUNT ON;


   DECLARE @CodeOfReference  as INT

	SELECT 
	      @CodeOfReference = CodeOfReference
	FROM DBO.CatStation
	WHERE IdStation = @IdStation

SELECT 
COUNT(PC.IdPromoCoupon) as TotalCuponesGenerados,
COUNT( CASE
           WHEN
		       PC.RowStatus = 0 
			   THEN PC.IdPromoCoupon
		END
		) 
		                                 TotalCuponesAnulados ,
COUNT( CASE
            WHEN
				PC.RowStatus=1 
				AND PC.GuideSerieDestination IS  NULL
				 THEN PC.IdPromoCoupon
		END 
		) 
		                                 TotalCuponesCanjeados,
COUNT( CASE
           WHEN
		            PC.RowStatus=1 
		 AND PC.GuideSerieDestination IS NOT NULL
		 THEN PC.IdPromoCoupon
		 END
		) 
	                                 TotalCuponesNoCanjeados,


SUM( 


   Isnull(PC.DiscountAmount,0)
	)			
		                                 TotalMontoGuideDestination,
SUM(  
	Isnull(PC.OriginalAmount,0)
				
	)	
     
		                                TotalMontoGuideOriginDestination,
SUM( Isnull(DO.PriceShippment,0)
			
	 ) 
		                                TotalMontoGuideOrigin,
		FORMAT(@DateOf, 'yyyy-MM-dd')  DateOf,
		FORMAT(@DateTo, 'yyyy-MM-dd')  DateTo 

FROM  dbo.PromoCoupon PC         WITH (NOLOCK)
LEFT JOIN  dbo.DeliveryOrder DO WITH (NOLOCK)
ON PC.GuideSerieOrigin  = DO.Guide_Serie AND  
   PC.GuideNumberOrigin = DO.Guide_Number
WHERE PC.DateCreated BETWEEN FORMAT(@DateOf, 'yyyy-MM-dd 00:00:00') 
                         AND FORMAT(@DateTo, 'yyyy-MM-dd 23:59:59')
						 AND PC.VisitPointClientOrigin = @CodeOfReference
						 AND PC.RowStatus = 1
	
END