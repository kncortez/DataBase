-- =============================================
-- Author:		<Author,Edelman,Vásquez>
-- Create date: <Create Date 2023-01-06>
-- Description:	<Description, SP para obtener código de referencia de credenciales para certificación FEL segun Exc por Id de estación>
-- =============================================
CREATE PROCEDURE [dbo].[GetCodeOfReferenceForStation]
@IdStation AS INT	
AS
BEGIN
	
	SET NOCOUNT ON;

BEGIN TRY
    
	SELECT 
	      CodeOfReference 
	FROM [dbo].[CatStation] WITH(NOLOCK)
	WHERE IdStation = @IdStation

END TRY
BEGIN CATCH
	 ROLLBACK

	 SELECT CodeOfReference  = 999
END CATCH
END