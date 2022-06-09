

-- =============================================
-- Author:		<Oscar,Morales>
-- Create date: <2021-06-23>
-- Description:	<Set excluido en guias por pagar COD>
-- =============================================

CREATE PROCEDURE [dbo].[SetGuidesToPayExcludedCOD] 
-- Add the parameters for the stored procedure here
	@BatchCODId int,
	@BatchDetailCODId int,
	@Excluded bit,
	@UserToken nvarchar(50)
AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
	DECLARE @GuideSerie nvarchar(2)=NULL;
	DECLARE @GuideNumber int=NULL;
	(select @GuideSerie=GuideSerie,@GuideNumber=GuideNumber from dbo.BatchDetailCOD where IdBatchDetailCOD=@BatchDetailCODId)

	if @GuideSerie IS NOT NULL AND @GuideNumber IS NOT NULL
	BEGIN	
		--Start Log
		INSERT INTO DBO.BatchDetailCODLog
		(
			BatchCODId,
			GuideSerie,
			GuideNumber,
			Excluded,
			RowStatus,
			TokenCreated,
			DateCreated,
			TokenUpdated,
			DateUpdated
		)VALUES
		(
			@BatchCODId,
			@GuideSerie,
			@GuideNumber,
			@Excluded,
			1,
			@UserToken,
			GETDATE(),
			@UserToken,
			GETDATE()
		);
		--End Log	
		UPDATE [dbo].[BatchDetailCOD] 
		SET [Excluded] = @Excluded
		WHERE [IdBatchDetailCOD] = @BatchDetailCODId
	END

		COMMIT TRANSACTION;  

	END TRY
	BEGIN CATCH  
			SELECT 'FALSE'	[blnResult]
				,CAST(ERROR_NUMBER() AS VARCHAR) AS [ErrorNumber]
				,CAST(ERROR_SEVERITY() AS VARCHAR) AS [ErrorSeverity]
				,CAST(ERROR_STATE() AS VARCHAR) AS [ErrorState]
				,CAST(ERROR_PROCEDURE() AS VARCHAR) AS [ErrorProcedure]
				,CAST(ERROR_LINE() AS VARCHAR) AS [ErrorLine]  
				,CAST(ERROR_MESSAGE() AS NVARCHAR(MAX)) AS [Message];  
			ROLLBACK TRANSACTION;  
	END CATCH;  
END