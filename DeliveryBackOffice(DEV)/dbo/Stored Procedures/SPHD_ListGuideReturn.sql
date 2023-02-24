-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2023-02-24>
-- Description:	<SP para listado de guía reimpresión>
-- =============================================
CREATE PROCEDURE [dbo].[SPHD_ListGuideReturn] 
	@TblListGuideActa TblListGuideActa READONLY,
	@Token NVARCHAR(50)
AS
BEGIN	
  
	SET NOCOUNT ON;

	BEGIN TRANSACTION
	BEGIN TRY
	
	
	DECLARE @Numero AS INT;
	DECLARE @Serie  AS NVARCHAR(2);
	DECLARE @STATUS AS INT; 
	DECLARE @RevalueGuides AS TABLE(
				GuideSerie NVARCHAR(2),
				GuideNumber INT)
	DECLARE @GuidesModify AS TABLE(
				GuideSerie NVARCHAR(2),
				GuideNumber INT)

	INSERT INTO @RevalueGuides
				SELECT
					SUBSTRING(lg.NumberGuidePice,1,2)
				    ,CAST(SUBSTRING(LTRIM(lg.NumberGuidePice), 3, CAST(LEN(lg.NumberGuidePice) AS INT)) AS INT)
				FROM @TblListGuideActa lg

------------Modificar Bandera campo IsLastMileReturn ----------------------------
WHILE EXISTS (SELECT TOP 1 1 FROM @RevalueGuides)
BEGIN
					SELECT TOP 1
						@Serie  =  rg.GuideSerie,
						@Numero =  rg.GuideNumber	
				   FROM @RevalueGuides rg

				   SELECT @STATUS = StatusOrderId
				   FROM [dbo].[DeliveryOrderDetail] WITH (NOLOCK)
				   WHERE Guide_Serie = @Serie AND Guide_Number = @Numero

				 
	DELETE FROM @RevalueGuides
	WHERE GuideSerie = @Serie AND GuideNumber = @Numero

END
			COMMIT TRANSACTION;
			SELECT GuideSerie,
				   GuideNumber 
			FROM @GuidesModify 
          
	   END TRY
			 BEGIN CATCH
				ROLLBACK TRANSACTION
				
			SELECT
			0 [blnResult]
			,ERROR_MESSAGE() [Description]
			,0 [NumTransferID]
			,ERROR_NUMBER() [ErrorNumber]
			,ERROR_SEVERITY() [ErrorSeverity]
			,ERROR_STATE() [ErrorState]
			,ERROR_PROCEDURE() [ErrorProcedure]
			,ERROR_LINE() [ErrorLine]
			,ERROR_MESSAGE() [ErrorMessage];
	  END CATCH




END