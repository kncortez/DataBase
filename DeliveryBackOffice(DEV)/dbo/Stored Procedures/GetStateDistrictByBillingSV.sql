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
      From TownshipDistrictByBillingSV tdbsv    WITH(NOLOCK)
           inner Join DistrictByBillingSV dbsv  WITH(NOLOCK)
              on dbsv.Id = tdbsv.DistrictId    
           inner Join StateByBillingSV    sbsv  WITH(NOLOCK)  
              on sbsv.Id = tdbsv.StateByBillingSVId    
           Inner Join Township t                WITH(NOLOCK) 
              on t.IdTownship = tdbsv.TownshipId    
           Inner Join Province p                WITH(NOLOCK)
              on p.IdProvince = t.IdProvince    
     Where t.IdProvince =  @IdProvince    
       and t.IdTownship = @IdTownship      
END