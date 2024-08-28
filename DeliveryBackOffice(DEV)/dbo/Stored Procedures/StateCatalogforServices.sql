
-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <26/09/26>
-- Description:	<SP desplegar catálogo de estados para servicios>
-- =============================================
CREATE PROCEDURE [dbo].[StateCatalogforServices] 
	@ServiceType NVARCHAR(50) = 'PICKUP'
AS
BEGIN
	
	SET NOCOUNT ON;

	BEGIN TRY
	IF (@ServiceType = 'PICKUP' )
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
			[Name] IN ('Recolectado', 'Incidencia')
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