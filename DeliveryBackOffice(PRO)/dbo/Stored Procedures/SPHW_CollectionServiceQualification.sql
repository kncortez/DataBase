-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-09-13>
-- Description:	<SP para calificación de servicio>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_CollectionServiceQualification] 
@Qualification AS BIT,
@IdSchedulePickup AS INT,
@comment AS NVARCHAR(100)

AS
BEGIN

     DECLARE @ID AS INT = (SELECT Top 1 IdSchedulePickup 
                           FROM  [dbo].[ServiceManagement] WITH (NOLOCK)
						   WHERE IdServiceManagement= @IdSchedulePickup)

	SET NOCOUNT ON;

	BEGIN TRANSACTION 
	BEGIN TRY
  
  IF ((SELECT TOP 1 ServiceRate FROM [dbo].[SchedulePickup] WITH (NOLOCK)
       WHERE SchedulePickupId = @ID ) IS NULL
	 )
  BEGIN

     UPDATE [dbo].[SchedulePickup] 
	 SET ServiceRate = @Qualification,
	     ServiceComment =@comment 
	 WHERE SchedulePickupId = @ID;

	 SELECT Result = 1,Descrip='Calificación exitosa';
  END
  ELSE
	  BEGIN 
	   SELECT Result= 0,Descrip='Ya fue calificado el servicio';
	  END

	  COMMIT TRANSACTION
	  END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION
			 SELECT Result= 0,Descrip='ERROR EN EL PROCESO';
			 		SELECT
			0 'ResponseCode'
		   ,ERROR_MESSAGE() 'Description'
		   ,ERROR_NUMBER() 'ErrorNumber'
		   ,ERROR_SEVERITY() 'ErrorSeverity'
		   ,ERROR_STATE() 'ErrorState'
		   ,ERROR_PROCEDURE() 'ErrorProcedure'
		   ,ERROR_LINE() 'ErrorLine';

		
	END CATCH

END