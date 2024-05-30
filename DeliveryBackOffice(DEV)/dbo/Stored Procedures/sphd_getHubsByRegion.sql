-- =============================================
-- Author: <Ixchop,Alberto>
-- Create date: <2022-01-28>
-- Description: <Obtiene el catalogo de hubs por region;lista de  hubs y lista de  regiones>
-- =============================================------------------------------------
-- =============================================
-- Author: <Daniel,Ramirez>
-- Update date: <2025-05-16>
-- Description: <Se agrega el filtro de pais, por defecto GT>
-- =============================================------------------------------------
CREATE PROCEDURE [dbo].[sphd_getHubsByRegion]
(
 @idCountry VARCHAR(2) = 'GT'
)
AS
BEGIN
    --Hubs y Regiones relacionados
    SELECT HubLogisticId HubId,
           HBR.RegionId RegionID
      FROM DBO.HubByRegion HBR WITH(NOLOCK)
           LEFT JOIN DBO.HubLogistics HL ON HBR.HubLogisticId = HL.IdHubLogistic
                                        AND HL.HubStatus = 1
           LEFT JOIN DBO.CatRegion CR ON CR.IdCatRegion = HBR.RegionId 
                                     AND CR.RowStatus = 1
     WHERE HBR.RowStatus=1
       AND IIF(CR.IdCountry IS NULL, 'GT', CR.IdCountry) = HL.IdCountry
       AND IIF(HL.IdCountry IS NULL, 'GT', HL.IdCountry) = @IdCountry
       AND HL.IdHubLogistic IS NOT NULL;
    --Catalogo de HUBs
    SELECT IdHubLogistic IdValue,
           HubAbbreviation+'-'+HubName NameValue
      FROM DBO.HubLogistics WITH(NOLOCK)
     WHERE HubStatus=1
       AND IIF(IdCountry IS NULL, 'GT', IdCountry) = @IdCountry
    --Catalogo de Regiones
    SELECT IdCatRegion IdValue,
           RegionName NameValue
      FROM DBO.CatRegion WITH(NOLOCK)
     WHERE RowStatus=1
       AND IIF(IdCountry IS NULL, 'GT', IdCountry) = @IdCountry;
END
