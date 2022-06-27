-- =============================================
-- Author:		<Author,,Edelman Vásquez>
-- Create date: <Create Date,3/06/2022>
-- Description:	<Description,Datos de Cupon, para visualizarlo en Modal desde ventana del HPW>
-- =============================================
CREATE PROCEDURE [dbo].[SPHWPCouponData]
	-- Add the parameters for the stored procedure here
  
    @Token VARCHAR(200),
    @IdAccount BIGINT,
    @GuideNumber AS NVARCHAR(50)
   
  
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @JsonResponse NVARCHAR(MAX) = '';
	DECLARE @JsonBreakdown NVARCHAR(MAX) = '';
    -- Insert statements for procedure here 

	
	SET @JsonResponse =  
		( 
	SELECT STUFF((
	SELECT ',{'+ 
	     '"IdResult":200,'+
	     '"Coupon":"' + PC.PromoCouponSerie +'"'+  ',' +
		 '"Date":"' + FORMAT( PC.DateCreated,'dd-MM-yyyy')+'"'+ ',' +
		 '"DateFinal":"' + FORMAT( PC.FinalActiveDate,'dd-MM-yyyy')+'"'+ ',' +
		 '"PromoDescription":"' + CP.PromoDescription + '",' +
		 '"DateUpdated":"' + ISNULL(FORMAT(PC.DateUpdated,'dd-MM-yyyy'),'')+'"'+ ',' +
		'"RedeemedDate":"' + ISNULL(FORMAT(PC.RedeemedDate,'dd-MM-yyyy'),'')+'"'+ ',' +
		'"GuideNumberDestination":"'+ ISNULL(PC.GuideSerieDestination + Convert(Varchar,PC.GuideNumberDestination),'') As GuideDestination, +'"'+ ',' +
		 '"Status":"'+
		 CASE
	            WHEN  PC.RedeemedDate IS NOT  NULL      THEN  'CANJEADO'
				WHEN  PC.RedeemedDate IS NULL AND PC.DateCreated <= PC.FinalActiveDate AND FORMAT(GETDATE(),'yyyy-MM-dd 23:59:59') <= PC.FinalActiveDate  
					  AND PC.RowStatus=1                THEN  'VALIDO'
                WHEN  PC.RowStatus=0                    THEN  'ANULADO'
	            WHEN  PC.FinalActiveDate < FORMAT(GETDATE(),'yyyy-MM-dd 23:59:59') 
				      AND  PC.RedeemedDate IS NULL AND PC.GuideNumberDestination IS NULL THEN  'NO VIGENTE'
				ELSE 'NO DEFINIDO'
		   END + '"' +
		   '}'
			
	FROM 
		 [DeliveryBackOffice].[dbo].PromoCoupon PC WITH (NOLOCK)
    INNER JOIN
		 [DeliveryBackOffice].[dbo].CatPromo CP	   WITH (NOLOCK)
	ON   PC.CatPromoId = CP.IdPromo
	WHERE	
	     PC.GuideNumberOrigin =convert(Int,@GuideNumber)
	ORDER BY PC.DateCreated Desc
	FOR XML PATH(''), TYPE 
	) 
			.value('.', 'varchar(max)'),1,1,'' 
			)
	)
  IF @JsonResponse  IS NULL
        BEGIN

            SET @JsonResponse  =
            (
                SELECT STUFF(
                                (
                                    SELECT '{{"IdResult":500,' + '"Message":"No se encontraron registros"}'
                                    FOR XML PATH(''), TYPE
                                ).value('.', 'varchar(max)'),
                                1,
                                1,
                                ''
                            )
            );
        END;

       -- SELECT ('[' + @jsonResult + ']') jsonResult;
		  SELECT  ( '[' + @JsonResponse + ']' )  JsonOutput 
END
