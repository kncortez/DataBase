-- =============================================    
-- Author:      <Cristian, Azurdia>    
-- Create date: <2024-06-29>    
-- Description: <Desplegar listado de Municipios, por Defecto el Salvador>    
-- =============================================    
CREATE PROCEDURE [dbo].[GetProvinceTownshipByBillingSV]
(
  @CodeState    NVARCHAR(4) = 0,
  @CodeDistrict NVARCHAR(4) = 0    
)    
AS    
BEGIN    
    
    select top 1
           p.IdProvince         IdProvince,
           t.IdTownship         IdTownship
      From TownshipDistrictByBillingSV tdbsv
           inner Join DistrictByBillingSV dbsv    
              on dbsv.Id = tdbsv.DistrictId    
           inner Join StateByBillingSV    sbsv    
              on sbsv.Id = tdbsv.StateByBillingSVId    
           Inner Join Township t    
              on t.IdTownship = tdbsv.TownshipId    
           Inner Join Province p    
              on p.IdProvince = t.IdProvince    
     Where dbsv.StateCode    = @CodeState   
       and dbsv.CodeDistrict = @CodeDistrict      
END