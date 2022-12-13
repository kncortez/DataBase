-- =============================================
-- Author:		<Edelman,Vásquez>
-- Create date: <2022-09-29>
-- Description:	<SP Para Validar que la estación se tipo hub=1, de ser  Ex C = 2 no permitir acceso a admin hub linehauls>
-- =============================================
CREATE PROCEDURE [dbo].[SPHD_ValidateStationType]
@IdStation AS INT
AS
BEGIN

	SET NOCOUNT ON;

    SELECT StationType 
	FROM dbo.CatStation 
	WHERE IdStation = @IdStation
END