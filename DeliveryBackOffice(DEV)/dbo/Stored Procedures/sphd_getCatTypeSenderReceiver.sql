-- =============================================
-- Author: <Ixchop,Alberto>
-- Create date: <2022-01-28>
-- Description: <Obtiene el catalogo de tipos de piloto>
-- =============================================
-- =============================================
-- Author:      <Daniel,Ramirez>
-- Update date: <2025-05-19>
-- Description: <Se agrega el parametro para filtrar por pais, valor por defecto GT>
-- =============================================
CREATE PROCEDURE [dbo].[sphd_getCatTypeSenderReceiver]
(
 @IdCountry VARCHAR(2) = 'GT'
)
AS
BEGIN
   SELECT IdCatTypeSenderReceiver IdValue,
          TypeName NameValue
     FROM DBO.CatTypeSenderReceiver CTSR  WITH(NOLOCK) 
    WHERE [CTSR].[RowStatus] = 1
      AND IIF(CTSR.IdCountry IS NULL, 'GT', CTSR.IdCountry) = @IdCountry
    ORDER BY [CTSR].[TypeName] ASC;
END
