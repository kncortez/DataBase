-- =============================================    
-- Author:      <Cristian, Azurdia>    
-- Create date: <2024-06-15>    
-- Description: <Desplegar listado de Municipios, por Defecto el Salvador>    
-- =============================================    
CREATE PROCEDURE [dbo].[GetStateDistrictByBillingSV]    
(    
  @IdProvince INT = 0,    
  @IdTownship INT = 0    
)    
AS    
BEGIN    
    
    select sbsv.Code         StateCode,    
           dbsv.CodeDistrict DistrictCode    
      From TownshipDistrictByBillingSV tdbsv    
           inner Join DistrictByBillingSV dbsv    
              on dbsv.Id = tdbsv.DistrictId    
           inner Join StateByBillingSV    sbsv    
              on sbsv.Id = tdbsv.StateByBillingSVId    
           Inner Join Township t    
              on t.IdTownship = tdbsv.TownshipId    
           Inner Join Province p    
              on p.IdProvince = t.IdProvince    
     Where t.IdProvince =  @IdProvince    
       and t.IdTownship = @IdTownship      
END