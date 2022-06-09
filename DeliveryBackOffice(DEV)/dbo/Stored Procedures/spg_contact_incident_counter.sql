



-- =============================================
-- Author:		<Carlos, Cano>
-- Create date: <2020-10-14>
-- Description:	<Obtiene la cantidad de confirmaciones de entrega e incidentes de contacto realizadas en el día por el área de SAC>
-- =============================================
CREATE PROCEDURE [dbo].[spg_contact_incident_counter]
	-- Add the parameters for the stored procedure here
	@IdUser NVARCHAR(50),
	@Username NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		COUNT(Guide_Number) AS Guides,
		COUNT(ID_ContactIncident) AS Total_ContactIncident,
		ISNULL(SUM(CAST(Contact_Confirmed AS INT)),0) AS Total_ContactConfirmed
	FROM DeliveryBackOffice.dbo.DeliveryOrder
	WHERE User_Contact IN (
		SELECT lbt.SSN_IdToken
		FROM DenariusUser_Dev.dbo.LGN_User u
		JOIN DenariusUser_Dev.dbo.LGN_LogByToken lbt ON lbt.SSN_IdUser = u.USR_IdUser AND lbt.SSN_Username = u.USR_Username
		WHERE u.USR_IdUser = @IdUser AND u.USR_Username = @Username AND CONVERT(VARCHAR, lbt.SSN_DateLogin, 23) = CONVERT(VARCHAR, GETDATE(), 23)
	)
END
