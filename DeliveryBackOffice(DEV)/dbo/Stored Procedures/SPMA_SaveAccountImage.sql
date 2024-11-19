-- =============================================
-- Author:		<Oscar Rodriguez>
-- Create date: <2024-11-19>
-- Description:	<Se agrego sp para manejo de imagenes de perfil para usuario en aplicacion Navenik>
-- =============================================
CREATE PROCEDURE [dbo].[SPMA_SaveAccountImage]
  @Token NVARCHAR(200),
  @PerfilImage NVARCHAR(500) = NULL
AS 
BEGIN 
	BEGIN TRANSACTION
	BEGIN TRY
		DECLARE @IdUser BIGINT = ( SELECT TOP 1 t.TknIdUser FROM TokenLog t WITH(NOLOCK) WHERE t.TknIdToken = @Token );
		DECLARE @IdAccount BIGINT =
				(
					SELECT ac.AccIdAccount FROM RolByUserByAccount rba WITH(NOLOCK)
						INNER JOIN Account ac WITH(NOLOCK)
						ON rba.RuaIdAccount = ac.AccIdAccount
						WHERE rba.RuaIdUser = @IdUser
				);

		UPDATE dbo.Account
		SET ImageProfile = ISNULL(@PerfilImage, ImageProfile),
			AccTokenUpdated = 'SYS-ADMIN-MOVIL-APP',
			AccDateUpdated = GETDATE()
		WHERE AccIdAccount = @IdAccount
		
		COMMIT TRANSACTION
		SELECT
		200 AS 'StatusCode',
		'Registro guardado correctamente' AS 'Description'
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SELECT
		400 AS 'StatusCode',
		'Error al registrar Link de Entrega' AS 'Description'
	END CATCH
END