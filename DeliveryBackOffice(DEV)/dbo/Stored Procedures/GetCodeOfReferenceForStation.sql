-- =============================================
-- Author:		<Author,Edelman,Vásquez>
-- Create date: <Create Date 2023-01-06>
-- Description:	<Description, SP para obtener código de referencia de credenciales para certificación FEL segun Exc por Id de estación>
-- =============================================
CREATE PROCEDURE [dbo].[GetCodeOfReferenceForStation]
	@IdStation AS INT = NULL
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @CodeOfReferenceStation INT;

	BEGIN TRY
    
		SET @CodeOfReferenceStation = (
			SELECT 
				CS.CodeOfReference 
			FROM 
				[DeliveryBackOffice].[dbo].[CatStation] CS WITH(NOLOCK)
			WHERE 
				CS.IdStation = @IdStation
		)

		IF(ISNULL(@CodeOfReferenceStation,0) = 0)
		BEGIN

			SELECT
				CodeOfRefrence = 999

		END
		ELSE
		BEGIN

			SELECT
				CodeOfReference = @CodeOfReferenceStation

		END

	END TRY
	BEGIN CATCH

		 SELECT CodeOfReference  = 999

	END CATCH
END