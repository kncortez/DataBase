
-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2024-12-13>
-- Description:	<Description,Correo para soporte para integraciones>
-- =============================================
CREATE PROCEDURE SPHWHelpRequest
@IdCountry NVARCHAR(2)	
AS
BEGIN

	SET NOCOUNT ON;

  DECLARE @SoportEmail NVARCHAR(100)=(  SELECT TOP 1  [Value] FROM [dbo].[ConfigParams] WITH(NOLOCK)
	                                                       WHERE [Name] ='SoportEmail' AND [IdCountry] = @IdCountry);
                        SELECT 1 [IdResult],
							  'Solicitud de ayuda a soporte' [Message],
							  @SoportEmail AS 'SoportEmail'


END
GO



