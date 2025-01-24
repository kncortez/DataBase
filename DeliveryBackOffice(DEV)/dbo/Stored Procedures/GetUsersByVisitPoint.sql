-- =============================================
-- Author:		<Tito Garcia>
-- Create date: <2024-12-12>
-- Description:	<Devuelve listado de usuarios por punto de visita>
-- =============================================
CREATE PROCEDURE [dbo].[GetUsersByVisitPoint] 
	@VisitPointId AS INT
AS
BEGIN	
	SET NOCOUNT ON;

	BEGIN TRY

		SELECT iu.IdUser AS Id
			, iu.Username AS UserName
			, ru.UsrEmail AS Email
		FROM DeliveryBackOffice.dbo.RegisterUser ru WITH (NOLOCK)
			INNER JOIN DeliveryBackOffice.dbo.InternalUser iu WITH (NOLOCK)
				ON ru.UsrIdUser = iu.RegisterUserID
			INNER JOIN DeliveryBackOffice.dbo.VisitPointByUser vpbu WITH (NOLOCK)
				ON iu.RegisterUserID = vpbu.RegisterUserID
		WHERE	ru.UsrRowStatus = 1 
			AND iu.RowStatus = 1
			AND vpbu.RowStatus = 1
			AND vpbu.IdVisitPointClient = @VisitPointId
		ORDER BY iu.IdUser DESC
        
		SELECT 1 AS 'StatusCode', 
        'SUCCESS' AS 'Description'

    END TRY 
	BEGIN CATCH

        SELECT 0 AS 'StatusCode', 
                ERROR_MESSAGE() AS 'Description' 
	
	END CATCH
END;