-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <26/09/26>
-- Description:	<SP desplegar catálogo de estados para servicios>
-- =============================================
CREATE PROCEDURE [dbo].[StateCatalogforServices_JARP] 
	@ServiceType NVARCHAR(50) = 'PICKUP'
AS
BEGIN
	
	SET NOCOUNT ON;

	BEGIN TRY
	IF (@ServiceType = 'PICKUP' COLLATE Latin1_General_CI_AI)
	BEGIN
		SELECT
			1 'IdServiceStatus',
			'Carga exitosa' 'Name'
		
		SELECT 
			IdServiceStatus,
			[Name] 
		FROM 
			dbo.CatServiceStatus WITH (NOLOCK)
		WHERE
			[Name] COLLATE Latin1_General_CI_AI IN ('Recolectado', 'Incidencia')
	END
	ELSE
	BEGIN

		SELECT
			1 'IdServiceStatus',
			'Carga exitosa' 'Name'
		
		SELECT IdServiceStatus,
				[Name] 
		FROM dbo.CatServiceStatus WITH (NOLOCK)

	END
	END TRY
	BEGIN CATCH

		SELECT
			2 'IdServiceStatus',
			'' 'Name'

	END CATCH
END