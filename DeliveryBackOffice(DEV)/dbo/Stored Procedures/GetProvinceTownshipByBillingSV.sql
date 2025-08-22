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
      From TownshipDistrictByBillingSV tdbsv   WITH(NOLOCK)
           inner Join DistrictByBillingSV dbsv WITH(NOLOCK)   
              on dbsv.Id = tdbsv.DistrictId    
           inner Join StateByBillingSV    sbsv WITH(NOLOCK)   
              on sbsv.Id = tdbsv.StateByBillingSVId    
           Inner Join Township t               WITH(NOLOCK)
              on t.IdTownship = tdbsv.TownshipId    
           Inner Join Province p               WITH(NOLOCK)
              on p.IdProvince = t.IdProvince    
     Where dbsv.StateCode    = @CodeState   
       and dbsv.CodeDistrict = @CodeDistrict      
END