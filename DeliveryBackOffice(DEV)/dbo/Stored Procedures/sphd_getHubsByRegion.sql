-- =============================================
-- Author: <Ixchop,Alberto>
-- Create date: <2022-01-28>
-- Description: <Obtiene el catalogo de hubs por region;lista de  hubs y lista de  regiones>
-- =============================================------------------------------------
-- =============================================
-- Author: <Daniel,Ramirez>
-- Update date: <2025-05-16>
-- Description: <Se agrega el filtro de pais, si es nulo sera igual a GT>
-- =============================================------------------------------------
CREATE PROCEDURE [dbo].[sphd_getHubsByRegion]
(
 @idCountry VARCHAR(2) = NULL
)
AS
BEGIN
    --Hubs y Regiones relacionados
    SELECT HubLogisticId HubId,
           HBR.RegionId RegionID, *
      FROM DBO.HubByRegion HBR
           LEFT JOIN DBO.HubLogistics HL ON HBR.HubLogisticId = HL.IdHubLogistic
                                        AND HL.HubStatus = 1
           LEFT JOIN DBO.CatRegion CR ON CR.IdCatRegion = HBR.RegionId 
                                     AND CR.RowStatus = 1
     WHERE HBR.RowStatus=1
       AND ((ISNULL(@idCountry,'') <> ''
           AND ISNULL(@idCountry,'') <> 'GT'
           AND CR.IdCountry = HL.IdCountry
           AND CR.IdCountry = @idCountry)
           OR
           (ISNULL(@idCountry,'') <> ''
           AND ISNULL(@idCountry,'') = 'GT'
           AND HL.IdCountry = @idCountry)
           OR
           (ISNULL(@idCountry,'') = ''
           AND CR.IdCountry IS NULL))
       AND HL.IdHubLogistic IS NOT NULL;
    --Catalogo de HUBs
    SELECT IdHubLogistic IdValue,
           HubAbbreviation+'-'+HubName NameValue, *
      FROM DBO.HubLogistics 
     WHERE HubStatus=1
       AND ((ISNULL(@idCountry,'') <> ''
           AND IdCountry = @idCountry)
           OR
           (ISNULL(@idCountry,'') = ''
           AND IdCountry = 'GT'));
    --Catalogo de Regiones
    SELECT IdCatRegion IdValue,
           RegionName NameValue,*
      FROM DBO.CatRegion
     WHERE RowStatus=1
       AND ((ISNULL(@idCountry,'') <> ''
           AND ISNULL(@idCountry,'') <> 'GT'
           AND IdCountry = @idCountry)
           OR
           (ISNULL(@idCountry,'') <> ''
            AND @idCountry = 'GT'
            AND IdCountry IS NULL)
           OR
           (ISNULL(@idCountry,'') = ''
           AND IdCountry IS NULL));
END
