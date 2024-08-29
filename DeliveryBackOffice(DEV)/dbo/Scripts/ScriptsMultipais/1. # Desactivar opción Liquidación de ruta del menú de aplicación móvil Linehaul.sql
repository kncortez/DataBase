--screjecutado 3
/* Desactivar opción Liquidación de ruta del menú de aplicación móvil Linehaul */

DECLARE @ModIdModule INT

SELECT @ModIdModule  = ModIdModule  FROM dbo.CatModule CM WITH(NOLOCK)
WHERE CM.ModName='Liquidación de ruta'

UPDATE [dbo].[CatModule]
SET ModRowStatus=0
WHERE ModIdModule = @ModIdModule