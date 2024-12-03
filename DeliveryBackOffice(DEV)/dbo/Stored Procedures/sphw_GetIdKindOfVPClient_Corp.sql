-- =============================================
-- Author:		<Tito Garcia>
-- Create date: <2024-11-26>
-- Description:	<Se obtiene el IdKingOfVPCliente>
-- =============================================
CREATE PROCEDURE [dbo].[sphw_GetIdKindOfVPClient_Corp]
@IdCountry NVARCHAR(2)	
AS
BEGIN
	SET NOCOUNT ON;

	SELECT IdKindOfVPClient
	FROM KindOfVPClient
	WHERE KindOfVPName = 'Corporativo'
		AND KindOfVPStatus = 1
		AND ISNULL(IdCountry,'GT') = @IdCountry
END
