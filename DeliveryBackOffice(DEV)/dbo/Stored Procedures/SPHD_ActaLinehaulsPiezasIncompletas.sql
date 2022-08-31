-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-08-09>
-- Description:	<SP para crear Acta de justificaciónd e piezas incompletas en las guías>
-- =============================================
CREATE PROCEDURE [dbo].[SPHD_ActaLinehaulsPiezasIncompletas] 
	@TblListGuideActa TblListGuideActa READONLY,
	@Token NVARCHAR(50),
	@ActType AS NVARCHAR(50),
	@ResponsibleName AS NVARCHAR(100)=NULL,
	@ResponsibleCUI  AS NVARCHAR(20)=NULL
	
AS
BEGIN	
   
	SET NOCOUNT ON;


	BEGIN TRANSACTION
	BEGIN TRY
	DECLARE @IdActaNew AS INT;
	DECLARE @IdActaDetailNew AS INT;
	
	DECLARE @Numero AS INT;
	DECLARE @Serie  AS NVARCHAR(2);
	DECLARE @PIEZAS AS INT;
	DECLARE @PICE AS NVARCHAR(20);
	DECLARE @RESULT AS INT=0;
	DECLARE @RevalueGuides AS TABLE(
				GuideSerie NVARCHAR(2),
				GuideNumber INT,
				Pice  NVARCHAR(20)
			)
	INSERT INTO @RevalueGuides
				SELECT
					SUBSTRING(lg.NumberGuidePice,1,2)
				    ,CAST(SUBSTRING(LTRIM(lg.NumberGuidePice), 3, CAST(LEN(NumberGuidePice) AS INT)-4) AS INT)
				    ,lg.NumberGuidePice
				FROM @TblListGuideActa lg



------Insert Actas---------------------------
			INSERT INTO [dbo].[Act]
			(
			CatRouteId,	
			DateOfRoute,
			ResponsibleName,
			ResponsibleCUI,	
			CatTypeActId,	
			AuthorizationDate,
			RowStatus,	
			TokenCreated,	
			DateCreated)
			VALUES (1, Getdate(),@ResponsibleName,@ResponsibleCUI,1,GETDATE(),1,@Token,GETDATE()) 
			SET @IdActaNew = SCOPE_IDENTITY();
------------Insert Detail Acta ----------------------------
WHILE EXISTS (SELECT TOP 1 1 FROM @RevalueGuides)
BEGIN
					SELECT TOP 1
						@Serie  =  rg.GuideSerie,
						@Numero =  rg.GuideNumber,
						@PICE =  rg.Pice
				   FROM @RevalueGuides rg


		 SET @RESULT=@RESULT+1;
		 INSERT INTO [dbo].[ActDetail]
		   (
		   ActId,	
		   GuideSerie,
		   GuideNumber,	
		   GuideDryPieceTotal,
		   GuideColdPieceTotal,	
		   DryPieceQuantity,	
		   ColdPieceQuantity,
		   RowStatus,
		   TokenCreated,
		   DateCreated	)
		   
		   VALUES (@IdActaNew,@Serie,@Numero,1,1,1,1,1,@Token,GETDATE())
		   SET @IdActaDetailNew = SCOPE_IDENTITY();


----------Insert Pice  of Actas-----------------
		   INSERT INTO [dbo].[ActDetailPiece](
		   	ActDetailId,
			PieceNumber,	
			IsDryPiece,	
			RowStatus,	
			TokenCreated,	
			DateCreated	
		   )
		   values(@IdActaDetailNew,
		   CAST(RIGHT(@PICE, 1) AS INT),
		   1,1,@Token,GETDATE())

	DELETE FROM @RevalueGuides
	WHERE Pice = @PICE;

END
			COMMIT TRANSACTION;
			SELECT @IdActaNew 
          
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