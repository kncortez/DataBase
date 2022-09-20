-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-09-13>
-- Description:	<SP  asignacón de servicio de recolección bajo selección de courier>
-- =============================================
CREATE PROCEDURE [dbo].[spHW_AssignRouteCollection]
@IdCurrierMan AS INT,
@IdRoute AS INT,
@IdVehicle AS INT,
@IdServiceManagment AS INT,
@Token AS NVARCHAR(50),
@IdRouteAssigment AS INT
AS
BEGIN

    DECLARE @IDRUTETYPE AS INT=NULL;
	
	SET NOCOUNT ON;

	SET @IDRUTETYPE =(SELECT IdTypeRoute FROM DBO.CatTypeRoute WITH (NOLOCK) WHERE Name ='Recolección' AND RowStatus=1);
BEGIN TRANSACTION
BEGIN TRY
   IF (EXISTS(
   
		SELECT Top 1 1
		FROM RouteAssigment RA WITH (NOLOCK)
		INNER JOIN CatRoute CR WITH (NOLOCK)
		ON RA.IdRoute = CR.IdRoute
		WHERE RA.IdCurrierMan = @IdCurrierMan AND 
		      RA.IdRoute = @IdRoute AND 
			  RA.IdVehicle = @IdVehicle AND 
			  CR.IdTypeRoute = @IDRUTETYPE AND RA.DateOfRoute=FORMAT(GETDATE(),'yyyy-MM-dd') 
       ))
	BEGIN

			
			UPDATE [DeliveryBackOffice].[dbo].[ServiceManagement]
				SET IdPuCourrier = @IdCurrierMan,
					IdPuRouteAssigment = @idRouteAssigment,
					ServiceStatusId = 2
				WHERE IdServiceManagement = @IdServiceManagment 
	
	         SELECT Result=1, Descrip='Ruta asignada exitosamente'

		COMMIT TRANSACTION

	END
		ELSE
		  BEGIN 
				SELECT Result=0, Descrip='Vehiculo no disponible'
		  END 

	END TRY
	BEGIN CATCH

        SELECT 0 [blnResult],
               ERROR_NUMBER() AS [ErrorNumber],
               ERROR_SEVERITY() AS [ErrorSeverity],
               ERROR_STATE() AS [ErrorState],
               ERROR_PROCEDURE() AS [ErrorProcedure],
               ERROR_LINE() AS [ErrorLine],
               ERROR_MESSAGE() AS [ErrorMessage];
		
		ROLLBACK TRANSACTION;
	END CATCH
	
END