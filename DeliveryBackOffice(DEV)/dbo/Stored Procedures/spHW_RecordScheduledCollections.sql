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
 @HubLogisticsId AS INT,
 @TokenAuthorized AS NVARCHAR(50),
 @DateAuthorized AS DATETIME,
 @RowStatus AS BIT,
 @DateCreated AS DATETIME,
 @TokenCreated AS  NVARCHAR(50)
AS
BEGIN
	

	SET NOCOUNT ON;

BEGIN TRANSACTION
BEGIN TRY
   
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
	TokenAuthorized,
	DateAuthorized,
	RowStatus,
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
	 @TokenAuthorized,
	 @DateAuthorized,
	 @RowStatus,
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