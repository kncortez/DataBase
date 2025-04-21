-- =============================================
-- Author:		<Author,Edelman,Vásquez>
-- Create date: <Create Date 2023-01-06>
-- Description:	<Description, SP para obtener código de referencia de credenciales para certificación FEL segun Exc por Id de estación>
-- =============================================
CREATE PROCEDURE [dbo].[GetCodeOfReferenceForStation]
	@IdStation AS INT = NULL
AS
BEGIN
	
	DECLARE @Country AS NVARCHAR(100) = (SELECT A1.CountryId FROM DeliveryBackOffice.dbo.CatStation A1 WITH(NOLOCK) 
	                    WHERE A1.IdStation = @IdStation )
    
	
	

	SET NOCOUNT ON;

	DECLARE @CodeOfReferenceStation INT;

	BEGIN TRY
    
		SET @CodeOfReferenceStation = (
			SELECT 
				CS.CodeOfReference 
			FROM 
				[DeliveryBackOffice].[dbo].[CatStation] CS WITH(NOLOCK)
				INNER JOIN 
				[DeliveryBackOffice].[dbo].[del_ParametrosFactura] Dpf WITH(NOLOCK)
			ON CS.CodeOfReference = Dpf.dpf_VpCodeOfReference
			WHERE 
				CS.IdStation = @IdStation
		)

		IF(ISNULL(@CodeOfReferenceStation,0) = 0)
		BEGIN

				IF (@Country ='GT') --BNHL Solución temporal
			BEGIN
			   SELECT CodeOfReference  = 999
			END
			ELSE IF (@Country ='HN')
			BEGIN
			    SELECT CodeOfReference  = 948850
			END
			--SELECT
			--	CodeOfReference = 999

		END
		ELSE
		BEGIN

			SELECT
				CodeOfReference = @CodeOfReferenceStation

		END

	END TRY
	BEGIN CATCH
		IF (@Country ='GT') --BNHL Solución temporal
		BEGIN
		   SELECT CodeOfReference  = 999
		END
		ELSE IF (@Country ='HN')
		BEGIN
		    SELECT CodeOfReference  = 948850
		END
		 --SELECT CodeOfReference  = 999

	END CATCH
END