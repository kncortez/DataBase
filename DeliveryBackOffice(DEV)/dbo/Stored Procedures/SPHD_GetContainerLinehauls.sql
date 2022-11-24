-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-11-15>
-- Description:	<SP mostrar contenedores existentes y activos>
-- =============================================
CREATE PROCEDURE [dbo].[SPHD_GetContainerLinehauls] 
@Serie AS NVARCHAR(10),
@Numero AS NVARCHAR(200)
AS
BEGIN
	
	SET NOCOUNT ON;

BEGIN TRY

	IF(@Serie='1' AND @Numero='1')
	BEGIN         
			SELECT ROW_NUMBER() OVER(ORDER BY C.IdContainer ) AS [No],
			   C.IdContainer ID, 
			 CTC.TypeContainerName,
			 CTC.TypeContainerSerie,
			   C.ContainerNumber,
			   C.ContainerDescription,
			   CASE
                    WHEN C.RowStatus=1 THEN 'Habilitado' 
					ELSE 'Deshabilitado' END [Status],
			   SUBSTRING(CONVERT(VARCHAR,C.DateCreated,103),0,11) AS DateCreated	   
			FROM dbo.Container C WITH(NOLOCK)
			INNER JOIN dbo.CatTypeContainer CTC WITH(NOLOCK)
			ON C.CatTypeContainerId=CTC.IdCatTypeContainer
			ORDER BY C.IdContainer 
	END
	   ELSE
	   BEGIN

			SELECT ROW_NUMBER() OVER(ORDER BY C.IdContainer) AS [No],
					   C.IdContainer ID, 
					 CTC.TypeContainerName,
					 CTC.TypeContainerSerie,
					   C.ContainerNumber,
					   C.ContainerDescription,
					   SUBSTRING(CONVERT(VARCHAR,CTC.DateCreated,103),0,10) AS DateCreated
				FROM dbo.Container C WITH(NOLOCK)
				INNER JOIN dbo.CatTypeContainer CTC WITH(NOLOCK)
				ON C.CatTypeContainerId=CTC.IdCatTypeContainer
				WHERE CTC.TypeContainerSerie= @Serie
					  AND C.ContainerNumber= @Numero
					  ORDER BY C.IdContainer 

			END
END TRY 
BEGIN CATCH

		ROLLBACK
		SELECT Result = 4
END CATCH
END