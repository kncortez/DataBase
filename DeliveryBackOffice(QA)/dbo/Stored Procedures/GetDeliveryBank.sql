-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2021-29-10>
-- Description:	<Obtiene el listado de bancos>
-- =============================================
CREATE PROCEDURE [dbo].[GetDeliveryBank]
	-- Add the parameters for the stored procedure here
	@IdBank INT = -1,
	@Country NVARCHAR(2) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT db.[Id_bank]
		, db.[Name]
		, ISNULL(db.[Acronym],'') Acronym
		, db.[Description]
		, db.[CardCode]
		, db.[Id_country]
	FROM DeliveryBank db
	WHERE (@IdBank = -1 OR db.Id_bank = @IdBank)
		AND  (@Country IS NULL OR db.Id_country = @Country)
		AND db.Id_status = 1
	ORDER BY db.[Name]

END
