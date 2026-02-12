/* =================================================
   SP:        [dbo].[GetRetroactiveReconciliation]
   Propósito: <Datos para reportes de reconciliación retroactiva>
   Autor:     <Cristian Azurdia>
   Historia:  <FDAPI-5384>
   Fecha:     2026-02-02
============================================
=== CHANGELOG ================================
-- 2026-02-02 | Historia/épica: FDAPI-5384 | Autor: Cristian Azurdia |
=========================================== */

CREATE PROCEDURE [dbo].[GetRetroactiveReconciliation]
(
 @BeginDate   DATE,
 @EndDate     DATE,
 @IdCountry   NVARCHAR(2),
 @IdCustomer  INT = NULL,
 @IdSystem    INT = NULL,
 @IdTypeSale  INT = NULL,
 @IdStatus    INT = NULL
)
AS
BEGIN

    SELECT [Guidedate]
         , [Guide]
         , [CustomerId]
         , [CustomerName]
         , [TypeSaleId]
         , [TypeSale]
         , [StatusId]
         , [Status]
         , [SystemId]
         , [NameSystem]
         , [Sender]
         , [Payment_method]
         , [Invoice]
         , [Attempt]
         , [Overweight]
         , [CountryId]
    FROM RetroActiveReconciliation
    WHERE CountryId = @IdCountry
      AND GuideDate >= @BeginDate
      AND GuideDate <= @EndDAte
      AND (@IdCustomer IS NULL OR CustomerId = @IdCustomer)
      AND (@IdSystem IS NULL OR   SystemId = @IdSystem)
      AND (@IdStatus IS NULL OR   StatusId = @IdStatus)
      AND (@IdTypeSale IS NULL OR TypeSaleId = @IdTypeSale)

     OPTION (RECOMPILE);

END