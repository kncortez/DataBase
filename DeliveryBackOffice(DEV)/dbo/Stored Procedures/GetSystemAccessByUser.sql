-- =============================================
-- Author:		<Tito Garcia>
-- Create date: <2024-12-12>
-- Description:	<Devuelve los sistemas a los que el usuario tiene acceso>
-- =============================================
CREATE PROCEDURE [dbo].[GetSystemAccessByUser] 
	@Code AS INT
AS
BEGIN	
	SET NOCOUNT ON;

	BEGIN TRY

        SELECT  cs.SysNameSystem, ur.UstStatus
        FROM DeliveryBackOffice.dbo.InternalUser iu WITH (NOLOCK)
            INNER JOIN DeliveryBackOffice.dbo.UserSystemRestriction ur WITH (NOLOCK)
                ON iu.RegisterUserID = ur.UstIdUser
            INNER JOIN DeliveryBackOffice.dbo.CatSystem cs WITH (NOLOCK)
                ON ur.UstIdSystem = cs.SysIdSystem
        WHERE ur.UstRowStatus = 1
            AND iu.IdUser = @Code
        
		SELECT 1 AS 'StatusCode', 
        'SUCCESS' AS 'Description'

    END TRY 
	BEGIN CATCH

        SELECT 0 AS 'StatusCode', 
                ERROR_MESSAGE() AS 'Description' 
	
	END CATCH
END;