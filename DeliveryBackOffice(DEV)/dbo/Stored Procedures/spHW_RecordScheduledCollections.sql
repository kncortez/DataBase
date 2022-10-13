-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-10-10>
-- Description:	<SP Nuevo método para registrar recolecciones programadas>
-- =============================================
CREATE PROCEDURE [dbo].[spHW_RecordScheduledCollections] 
 @StartDate AS DATETIME,
 @EndDate AS DATETIME,
 @SenderID AS INT,
 @SenderName AS NVARCHAR(200),
 @SenderAddress AS NVARCHAR(600),
 @SpecialInstructions AS NVARCHAR(600),
 @EstimatedPackages AS INT,
 @TypeVehicleId AS INT,
 @DateCreated AS DATETIME, 
 @TokenCreated AS  NVARCHAR(50) 
AS
BEGIN
	

	SET NOCOUNT ON;

BEGIN TRANSACTION
BEGIN TRY
   

   DECLARE  @HubLogisticsId AS INT
   DECLARE  @GuideSerie AS NVARCHAR
   DECLARE  @GuideNumber AS INT


   SELECT  TOP 1  
                  @GuideNumber = Guide_Number ,
				  @GuideSerie  = Guide_Serie			  
   FROM dbo.DeliveryOrder WITH (NOLOCK)
   WHERE Sender_ID = @SenderID 
        AND CONVERT(DATE,DateCreated) = @StartDate
   ORDER BY DateCreated DESC

   SELECT TOP 1
                 @HubLogisticsId = hub.IdHubLogistic
                FROM dbo.DeliveryOrder dsg WITH (NOLOCK)
                    LEFT JOIN dbo.Township twn WITH (NOLOCK)
                        ON twn.IdTownship = dsg.SenderIdTownship
                    LEFT JOIN dbo.Township twc WITH (NOLOCK)
                        ON twc.TownshipName = dsg.Receiver_Town
                    LEFT JOIN
                    (
                        SELECT CV.HeaderCode,
                               MAX(CV.Hub) HUB
                        FROM dbo.DumpServiceCoverage CV WITH (NOLOCK)
                        GROUP BY CV.HeaderCode
                    ) HB
                        ON HB.HeaderCode = ISNULL(twn.HeaderCode, twc.HeaderCode)
                    LEFT JOIN dbo.HubLogistics hub WITH (NOLOCK)
                        ON hub.HubAbbreviation = HB.HUB  
                WHERE dsg.Guide_Serie = @GuideSerie
                      AND dsg.Guide_Number = @GuideNumber
 

					

   INSERT INTO [DeliveryBackOffice].[dbo].[SchedulePickupToProcess]
   (
  	StartDate,
	EndDate,
	SenderID,
	SenderName,
	SenderAddress,
	SpecialInstructions,
	EstimatedPackages,
	TypeVehicleId,
	HubLogisticsId,
	DateCreated,
	TokenCreated
   )
   VALUES
   (
	 @StartDate,
	 @EndDate,
	 @SenderID,
	 @SenderName,
	 @SenderAddress,
	 @SpecialInstructions,
	 @EstimatedPackages,
	 @TypeVehicleId,
	 @HubLogisticsId,
	 @DateCreated,
	 @TokenCreated 
   )

	COMMIT TRANSACTION

	SELECT Result = 1;
	END TRY
		BEGIN CATCH

			ROLLBACK TRANSACTION
			SELECT Result = 0;

		END CATCH
END