-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <2021-04-21>
-- Description:	<Devuelve los datos del usuario logueado>
-- =============================================
CREATE PROCEDURE [dbo].[sphdGetModuleAccess]
	-- Add the parameters for the stored procedure here
	@CodeUser as bigint,
	@UserName as nvarchar(50),
	@IdSystem as int 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT RUS.[RusIdRol]
		  ,RUS.[RusIdSystem]
		  ,RUS.[RusIdUser]
		  ,INU.IdEmployee
		  ,INU.IdUser
		  ,INU.Username
		  ,RMS.RmsIdModule
		  ,MDL.ModIdModuleParent
		  ,MDL.ModName
		  ,MDL.ModPath
		  ,MDL.ModOrder
		  ,MDL.ModMetadata
	  FROM [DeliveryBackOffice].[dbo].InternalUser INU 
	  JOIN [DeliveryBackOffice].[dbo].[RolByUserBySystem] RUS
									ON INU.RegisterUserID = RUS.RusIdUser AND INU.RowStatus = 'TRUE'
	  JOIN [DeliveryBackOffice].[dbo].RolByModuleBySystem RMS  ON RMS.RmsIdRol = RUS.RusIdRol 
									AND RUS.RusIdSystem = RMS.RmsIdSystem 
								    AND RUS.RusRowStatus  = 'TRUE'
	  JOIN CatModule MDL			ON RMS.RmsIdModule = MDL.ModIdModule
									AND MDL.ModRowStatus = 'TRUE'
	  WHERE INU.IdUser = @CodeUser
	  AND INU.Username = @UserName
	  AND RUS.RusIdSystem = @IdSystem  

	  	   
END
