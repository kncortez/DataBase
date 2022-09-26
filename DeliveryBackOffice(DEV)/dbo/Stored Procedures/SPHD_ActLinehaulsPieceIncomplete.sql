-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-08-09>
-- Description:	<SP para crear Acta de justificaciónd e piezas incompletas en las guías>
-- =============================================
CREATE PROCEDURE [dbo].[SPHD_ActLinehaulsPieceIncomplete] 
	@TblListGuideActa TblListGuideActa READONLY,
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
	DECLARE @RevalueGuides AS TABLE(
				GuideSerie NVARCHAR(2),
				GuideNumber INT,
				Pice  NVARCHAR(20)
			)
	INSERT INTO @RevalueGuides
				SELECT
					SUBSTRING(lg.NumberGuidePice,1,2),
				    CAST(
					SUBSTRING(lg.NumberGuidePice,3, 
					CHARINDEX('-',lg.NumberGuidePice)-3)  AS INT),
				    lg.NumberGuidePice
				FROM @TblListGuideActa lg
				ORDER BY lg.NumberGuidePice ASC

					
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
WHILE EXISTS (SELECT TOP 1 1 FROM @RevalueGuides )
BEGIN
					SELECT TOP 1
						@Serie  =  rg.GuideSerie,
						@Numero =  rg.GuideNumber,
						@PICE =    rg.Pice
				   FROM @RevalueGuides rg ORDER BY GuideSerie+CAST(GuideNumber AS VARCHAR)+'-'+ CAST(Pice AS VARCHAR) ASC
				   

	   SET  @DryPieceQuantity  =  @DryPieceQuantity  + (SELECT COUNT(NoPiece)  FROM dbo.DeliveryOrderPiece WITH(NOLOCK) WHERE GuideSerie = @Serie AND GuideNumber = @Numero AND IsDry = 1 AND NoPiece = CAST(SUBSTRING(@PICE,CHARINDEX('-',@PICE)+1,3) AS INT))
	   SET  @ColdPieceQuantity =  @ColdPieceQuantity + (SELECT COUNT(NoPiece)  FROM dbo.DeliveryOrderPiece WITH(NOLOCK) WHERE GuideSerie = @Serie AND GuideNumber = @Numero AND IsDry = 0 AND NoPiece = CAST(SUBSTRING(@PICE,CHARINDEX('-',@PICE)+1,3) AS INT)) 
	   SET  @RESULT=@RESULT+1;

	   IF (NOT EXISTS(SELECT TOP 1 1 FROM dbo.ActDetail WITH (NOLOCK) WHERE GuideSerie=@Serie AND GuideNumber=@Numero AND ActId=@IdActaNew))
	  
	   BEGIN
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
		   
		   VALUES (@IdActaNew,
		           @Serie,
				   @Numero,
		           (SELECT COUNT(ISNULL(NoPiece,0))  FROM dbo.DeliveryOrderPiece WITH(NOLOCK) WHERE GuideSerie = @Serie AND GuideNumber = @Numero AND IsDry=1),
				   (SELECT COUNT(ISNULL(NoPiece,0))  FROM dbo.DeliveryOrderPiece WITH(NOLOCK) WHERE GuideSerie = @Serie AND GuideNumber = @Numero AND IsDry=0),
				   @DryPieceQuantity,
				   @ColdPieceQuantity,
				   1,
				   @Token,
				   GETDATE()
				   )
		   SET @IdActaDetailNew = SCOPE_IDENTITY();

		  END

		   
----------Insert Pice  of Actas-----------------
		   INSERT INTO [dbo].[ActDetailPiece](
		   	ActDetailId,
			PieceNumber,	
			IsDryPiece,	
			RowStatus,	
			TokenCreated,	
			DateCreated	
		   )
		   values(
		   @IdActaDetailNew,
		   CAST(SUBSTRING(@PICE,CHARINDEX('-',@PICE)+1,3) AS INT),
		   (SELECT COUNT(NoPiece)  FROM dbo.DeliveryOrderPiece WITH(NOLOCK) WHERE GuideSerie = @Serie AND GuideNumber = @Numero AND IsDry=1 AND NoPiece=CAST(RIGHT(@PICE, 1) AS INT)),
		   1,
		   @Token,
		   GETDATE()
		   )

	DELETE FROM @RevalueGuides
	WHERE Pice = @PICE;

END
           UPDATE [dbo].[ActDetail] 
			SET DryPieceQuantity = @DryPieceQuantity, 
			    ColdPieceQuantity = @ColdPieceQuantity 
			WHERE ActId =@IdActaNew 


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