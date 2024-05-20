-- =============================================
-- Author: <Ixchop,Alberto>
-- Create date: <2022-01-28>
-- Description: <Obtiene el catalogo de tipos de piloto>
-- =============================================
-- =============================================
-- Author:      <Daniel,Ramirez>
-- Update date: <2025-05-19>
-- Description: <Se agrega el parametro para filtrar por pais, valor por defecto filtra GT, para GT el valor de IdCountry es nulo >
-- =============================================
CREATE PROCEDURE [dbo].[sphd_getCatTypeSenderReceiver]
(
 @idCountry VARCHAR(2) = NULL
)
AS
BEGIN
   SELECT IdCatTypeSenderReceiver IdValue,
          TypeName NameValue, CTSR.*
     FROM DBO.CatTypeSenderReceiver CTSR  WITH(NOLOCK) 
    WHERE [CTSR].[RowStatus] = 1
      AND ((ISNULL(@idCountry,'') <> ''
           AND ISNULL(@idCountry,'') <> 'GT'
           AND IdCountry = @idCountry)
           OR
           (ISNULL(@idCountry,'') <> ''
            AND @idCountry = 'GT'
            AND IdCountry IS NULL)
           OR
           (ISNULL(@idCountry,'') = ''
            AND IdCountry IS NULL))
    ORDER BY [CTSR].[TypeName] ASC;
END
