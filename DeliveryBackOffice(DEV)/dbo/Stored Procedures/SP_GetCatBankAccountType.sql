-- =============================================  
-- Author:  <Aylinne Recinos>  
-- Create date: <2024-28-10>  
-- Description: <Método para obtener los tipos de cuenta disponibles por país>  
-- =============================================  
  
CREATE PROCEDURE [dbo].[SP_GetCatBankAccountType]  
@CountryId NVARCHAR(5)  
AS  
BEGIN  
    SELECT  [BankAccountType],
            [IdBankAccountType]   
    FROM CatBankAccountType  
    WHERE IdCountry = @CountryId and RowStatus = 1  
END;