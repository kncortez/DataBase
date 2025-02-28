-- =============================================
-- Author:		<Aylinne Recinos>
-- Create date: <2025-28-01>
-- Description:	<Método obtener el AccountId del telefono del destinatario>
-- =============================================
CREATE PROCEDURE [dbo].[SPWS_GetAccountFromPhone]
@Phone NVARCHAR(20)
AS
BEGIN
  	DECLARE @ReceiverPhone NVARCHAR(8) = RIGHT(LTRIM(RTRIM(@Phone)), 8)

	SELECT TOP 1 rua.RuaIdAccount AS [IdAccount] FROM RegisterUser us
	INNER JOIN [dbo].[RolByUserByAccount] rua WITH (NOLOCK) ON rua.RuaIdUser = us.UsrIdUser
	WHERE us.Phone = @ReceiverPhone
END