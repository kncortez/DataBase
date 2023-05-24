-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2023-05-19>
-- Description:	<Description, Guardar registros de preparación de rutas especiales>
-- =============================================
CREATE PROCEDURE [dbo].[SpSaveRegisterPreparationRouteEspecial]

@IdCatRoute AS INT,
@IdCatVehicle AS INT,
@IdCatRouteCluster AS INT,
@IdRouteSupervisor AS INT,
@IdRouteLeader AS INT,
@SenderReceiverId AS INT=1,
@Coordinator AS NVARCHAR(150),
@RowStatus AS  BIT=1,
@TokenCreated AS  NVARCHAR(50),
@TblGuides TblGuides READONLY

AS
BEGIN	

		DECLARE @TSERoutePreparationDetail AS INT

		
		BEGIN TRANSACTION
			BEGIN TRY
         
		 IF (Exists(Select  1  From  [dbo].[TSERoutePreparationHeader] RP  Where RP.IdCatRoute = @IdCatRoute And RP.IdCatRouteCluster = @IdCatRouteCluster))
		 BEGIN

			 UPDATE [dbo].[TSERoutePreparationHeader] 
			      SET IdCatVehicle = @IdCatVehicle, 
				      IdCatRouteCluster = @IdCatRouteCluster,
					  IdRouteSupervisor = @IdRouteSupervisor,
				      IdRouteLeader = @IdRouteLeader,
					  DateUpdated = Getdate(),
					  TokenUpdated = @TokenCreated
			  Where IdCatRoute = @IdCatRoute 
			  And IdCatRouteCluster = @IdCatRouteCluster

			  SELECT 2 [blnResult]

		 END
		 ELSE
		   BEGIN
				INSERT INTO [dbo].[TSERoutePreparationHeader]
				(
					IdCatRoute,
					IdCatVehicle,
					IdCatRouteCluster,
					IdRouteSupervisor,
					IdRouteLeader,
					SenderReceiverId,
					Coordinator,
					DateCreated,
					TokenCreated
	
				)VALUES
				(

					@IdCatRoute,
					@IdCatVehicle,
					@IdCatRouteCluster,
					@IdRouteSupervisor,
					@IdRouteLeader,
					 @SenderReceiverId,
					@Coordinator,
					GETDATE(),
					@TokenCreated
	
	
				)

				SET @TSERoutePreparationDetail = SCOPE_IDENTITY()

					INSERT INTO [dbo].[TSERoutePreparationDetail]
					(
					 TSERoutePreparationHeaderID,
					 GuideSerie,
					 GuideNumber,
					 DateCreated,
					 TokenCreated
	 
					) 
					SELECT
						@TSERoutePreparationDetail,
						gp.Guide_Serie,
						gp.Guide_Number,
						GETDATE(),
						@TokenCreated
					FROM @TblGuides gp
	


	

	SELECT 1 [blnResult]

	END

	COMMIT TRANSACTION

	

	END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION

	SELECT    0 [blnResult],
               ERROR_NUMBER() AS [ErrorNumber],
               ERROR_SEVERITY() AS [ErrorSeverity],
               ERROR_STATE() AS [ErrorState],
               ERROR_PROCEDURE() AS [ErrorProcedure],
               ERROR_LINE() AS [ErrorLine],
               ERROR_MESSAGE() AS [ErrorMessage];
END CATCH



END