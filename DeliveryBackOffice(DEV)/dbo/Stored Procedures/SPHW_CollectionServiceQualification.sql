-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-09-13>
-- Description:	<SP para calificación de servicio>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_CollectionServiceQualification] 
@GuideSerie AS NVARCHAR(2),
@GuideNumber AS INT,
@Qualification AS BIT,
@IdSchedulePickup AS INT

AS
BEGIN

     

	SET NOCOUNT ON;

  
  IF ((SELECT TOP 1 ServiceRate FROM [dbo].[SchedulePickup]  WHERE SchedulePickupId= @IdSchedulePickup) IS NULL)
  BEGIN

     UPDATE [dbo].[SchedulePickup] 
	 SET ServiceRate = @Qualification
	 WHERE SchedulePickupId = @IdSchedulePickup

	 SELECT Result= 1
  END
  ELSE
  BEGIN 
   SELECT Result= 0
  END

END