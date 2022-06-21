-- =============================================
-- Author:		<Author,EDELMAN VASQUEZ>
-- Create date: <Create Date,2022-06-09>
-- Description:	<Description, REPORTE GENERAL DE CUPONES Y PROMOCIONES>
-- =============================================
CREATE PROCEDURE [dbo].[SPHD_CouponReportHeader]
    -- Add the parameters for the stored procedure here
    @DateOf AS DATE,
    @DateTo AS DATE
AS
BEGIN

    SET NOCOUNT ON;

    SELECT COUNT(PC.IdPromoCoupon) AS TotalCuponesGenerados,
           COUNT(   CASE
                        WHEN PC.RowStatus = 0 THEN
                            PC.IdPromoCoupon
                    END
                ) TotalCuponesAnulados,
           COUNT(   CASE
                        WHEN PC.RowStatus = 1
                             AND PC.GuideSerieDestination IS NULL THEN
                            PC.IdPromoCoupon
                    END
                ) TotalCuponesCanjeados,
           COUNT(   CASE
                        WHEN PC.RowStatus = 1
                             AND PC.GuideSerieDestination IS NOT NULL THEN
                            PC.IdPromoCoupon
                    END
                ) TotalCuponesNoCanjeados,
           SUM(   CASE
                      WHEN PC.RowStatus = 1
                           AND PC.GuideSerieDestination IS NOT NULL THEN
                          ISNULL(PC.FinalAmount, 0)
                  END
              ) TotalMontoCuponesCanjeados,
           SUM(ISNULL(PC.DiscountAmount, 0)) TotalMontoCuponesDescuento,
           SUM(ISNULL(PC.OriginalAmount, 0)) TotalMontoCuponesGenerado,
           FORMAT(@DateOf, 'yyyy-MM-dd') DateOf,
           FORMAT(@DateTo, 'yyyy-MM-dd') DateTo
    FROM dbo.PromoCoupon PC
    WHERE PC.DateCreated
    BETWEEN FORMAT(@DateOf, 'yyyy-MM-dd 00:00:00') AND FORMAT(@DateTo, 'yyyy-MM-dd 23:59:59');

END;