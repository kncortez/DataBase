-- =============================================
-- Author:		<Edelman>
-- Create date: <2022-11-30>
-- Description:	<SP Método para listar usuarios internos de un rol especificado>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_ListInternalUsersofaSpecifiedRole]
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @IdSystem AS nvarchar(150)
	BEGIN TRY
	

	SELECT TOP 1 @IdSystem = RolIdSystem FROM [dbo].[CatRol] WITH(NOLOCK) WHERE RolName='Operaciones web'


		SELECT DISTINCT
			 RUS.[RusIdUser]
			,INU.IdUser
			,INU.Username
		FROM [DeliveryBackOffice].[dbo].[SenderReceiverByUser] SRU 
		   INNER JOIN 
		   [DeliveryBackOffice].[dbo].[RolByUserBySystem] RUS WITH(NOLOCK)
		ON SRU.UserId = RUS.[RusIdUser]
		   INNER JOIN   [DeliveryBackOffice].[dbo].[InternalUser] INU WITH(NOLOCK)
		ON INU.RegisterUserID = RUS.RusIdUser AND INU.RowStatus = 'TRUE'
		   INNER JOIN [DeliveryBackOffice].[dbo].RolByModuleBySystem RMS   WITH(NOLOCK)
		ON RMS.RmsIdRol = RUS.RusIdRol AND RUS.RusIdSystem = RMS.RmsIdSystem AND RUS.RusRowStatus  = 'TRUE'
		   INNER JOIN CatModule MDL	WITH(NOLOCK)	
		ON RMS.RmsIdModule = MDL.ModIdModule AND MDL.ModRowStatus = 'TRUE'
		WHERE RUS.RusIdSystem = @IdSystem   AND SRU.RowStatus=1




   END TRY
   BEGIN CATCH
     ROLLBACK
	 SELECT  [blnResult]=0
   END CATCH
END