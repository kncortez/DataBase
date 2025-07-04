
-- =============================================
-- Author:  <Brandon Pedroza>  
-- Create date: <02-07-2025>  
-- Description: <Se agrega parametro para filtrar por país>  
-- =============================================  
CREATE PROCEDURE [dbo].[spHM_GetConfigParamsByCountry]
	@Name AS VARCHAR(50),
	@IdCountry AS NVARCHAR(2) = 'GT'
AS  
BEGIN  
 SET NOCOUNT ON;  
  
    SELECT [CP].[ConfigParamsId],  
           [CP].[Name],  
           [CP].[Description],  
           [CP].[Value]  
    FROM [dbo].[ConfigParams] CP  WITH(NOLOCK)
    WHERE [CP].[Name] = @Name  
      AND [CP].[Status] = 1  
      AND ISNULL([CP].[IdCountry],'GT') = @IdCountry;
END  