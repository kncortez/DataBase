-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-08-09>
-- Description:	<SP para crear Acta de justificaciónd e piezas incompletas en las guías>
-- =============================================
CREATE PROCEDURE [dbo].[SPHD_ActLinehaulsPieceIncomplete] 
	@TblListGuidePiece TblListGuidePiece READONLY,
	@Token AS NVARCHAR(50),
	@ActType AS NVARCHAR(50),
	@ResponsibleName AS NVARCHAR(100)=NULL,
	@ResponsibleCUI  AS NVARCHAR(20)=NULL,
	@CodeRoute AS NVARCHAR(10)=NULL
	
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
	DECLARE @DryPieceQuantity AS INT=0;	
	DECLARE	@ColdPieceQuantity AS INT=0;
	DECLARE @RESULT AS INT=0;
	DECLARE @IdRoute AS INT;

					
		SELECT @IdRoute = CR.IdRoute FROM dbo.CatRoute CR WITH (NOLOCK) where CodeRoute = @CodeRoute  		    

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
			VALUES (
			        @IdRoute, 
			        Getdate(),
					@ResponsibleName,
					@ResponsibleCUI,
					(SELECT Top 1 IdCatTypeAct FROM CatTypeAct WHERE ActName = @ActType),
					GETDATE(),
					1,
					@Token,
					GETDATE()) 
			SET @IdActaNew = SCOPE_IDENTITY();
------------Insert Detail Acta ----------------------------
	INSERT INTO [dbo].[ActDetail] (ActId,
	GuideSerie,
	GuideNumber,
	GuideDryPieceTotal,
	GuideColdPieceTotal,
	DryPieceQuantity,
	ColdPieceQuantity,
	RowStatus,
	TokenCreated,
	DateCreated)
		SELECT DISTINCT
			@IdActaNew
		   ,tlgp.GuideSerie
		   ,tlgp.GuideNumber
		   ,(SELECT
					COUNT(1)
				FROM DeliveryOrderPiece dop WITH (NOLOCK)
				WHERE tlgp.GuideSerie = dop.GuideSerie
				AND tlgp.GuideNumber = dop.GuideNumber
				AND (dop.IsDry = 1
				OR dop.IsDry IS NULL))
		   ,(SELECT
					COUNT(1)
				FROM DeliveryOrderPiece dop WITH (NOLOCK)
				WHERE tlgp.GuideSerie = dop.GuideSerie
				AND tlgp.GuideNumber = dop.GuideNumber
				AND dop.IsDry = 0)
		   ,(SELECT
					COUNT(1)
				FROM DeliveryOrderPiece dop WITH (NOLOCK)
				INNER JOIN @TblListGuidePiece tlgp2
					ON dop.GuideSerie = tlgp2.GuideSerie
					AND dop.GuideNumber = tlgp2.GuideNumber
					AND dop.NoPiece = tlgp2.NoPiece
				WHERE tlgp.GuideSerie = dop.GuideSerie
				AND tlgp.GuideNumber = dop.GuideNumber
				AND (dop.IsDry = 1
				OR dop.IsDry IS NULL))
		   ,(SELECT
					COUNT(1)
				FROM DeliveryOrderPiece dop WITH (NOLOCK)
				INNER JOIN @TblListGuidePiece tlgp2
					ON dop.GuideSerie = tlgp2.GuideSerie
					AND dop.GuideNumber = tlgp2.GuideNumber
					AND dop.NoPiece = tlgp2.NoPiece
				WHERE tlgp.GuideSerie = dop.GuideSerie
				AND tlgp.GuideNumber = dop.GuideNumber
				AND dop.IsDry = 0)
		   ,1
		   ,@Token
		   ,GETDATE()
		FROM @TblListGuidePiece tlgp

		----------Insert Pice  of Actas-----------------
	INSERT INTO [dbo].[ActDetailPiece] (ActDetailId,
	PieceNumber,
	IsDryPiece,
	RowStatus,
	TokenCreated,
	DateCreated)
		SELECT
			ad.IdActDetail
		   ,tlgp.NoPiece
		   ,ISNULL(dop.IsDry, 1)
		   ,1
		   ,@Token
		   ,GETDATE()
		FROM @TblListGuidePiece tlgp
		INNER JOIN ActDetail ad WITH (NOLOCK)
			ON tlgp.GuideSerie = ad.GuideSerie
				AND tlgp.GuideNumber = ad.GuideNumber
		INNER JOIN DeliveryOrderPiece dop WITH (NOLOCK)
			ON tlgp.GuideSerie = dop.GuideSerie
				AND tlgp.GuideNumber = dop.GuideNumber
				AND tlgp.NoPiece = dop.NoPiece


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