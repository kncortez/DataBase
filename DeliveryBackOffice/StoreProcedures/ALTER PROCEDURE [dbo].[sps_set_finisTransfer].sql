USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[sps_set_finisTransfer]    Script Date: 29/12/2021 12:25:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sps_set_finisTransfer]
	@TblListGuides AS TblListGuidesTransfer READONLY,
	@IdCourier INT,
	@CourierName VARCHAR(50),
	@DPI VARCHAR(15),
	@TokenCreated VARCHAR(100)

	AS

		BEGIN

    SET NOCOUNT ON;

		IF OBJECT_ID('tempdb.dbo.#listGuidesEnabled', 'U') IS NOT NULL DROP TABLE #listGuidesEnabled;
		

	DECLARE @jsonResult NVARCHAR(MAX) = '';
    DECLARE @errorMessage NVARCHAR(100);

	BEGIN TRANSACTION

    BEGIN TRY

          -- INSERT INTO TEMPORARY TABLE
          SELECT * 
			    INTO #listGuidesEnabled
			    FROM @TblListGuides


          -- INSERT INTO TRANSFERLOG SO WE CAN MONITOR ALL THE GUIDES THAT WERE TRANSFER TO A EXPRESS CENTER

           INSERT INTO DeliveryBackOffice.dbo.TransferLog(
                      [IdCourier],
                      [CourierName],
                      [DPI],
                      [IdIncidence],
                      [IncidenceName],
                      [Comentary],
                      [GuideSerie],
                      [GuideNumber],
                      [TokenCreated],
                      [DateCreated]

                      )
           SELECT 
			          @IdCourier,
			          @CourierName,
			          @DPI,
			          iif(lge.IdIncidence=-1,null,lge.IdIncidence), 
			          iif(lge.IdIncidence=-1,null,lge.IncidenceName),
			          lge.Comentary,
		              lge.Guide_Serie,
		              lge.Guide_Number,
			          @TokenCreated,
			          GETDATE()
		  FROM #listGuidesEnabled lge;

          --UPDATE ON DELIVERY ORDER TO STATUS "Traslado a Express Center"
          UPDATE DeliveryBackOffice.dbo.DeliveryOrder
				  SET StatusOrderId = 20
				  FROM DeliveryBackOffice.dbo.DeliveryOrder do
				  JOIN #listGuidesEnabled lge ON lge.Guide_Number= do.Guide_Number AND lge.Guide_Serie=do.Guide_Serie;
						 
		UPDATE DeliveryBackOffice.dbo.DeliverySettlementDetail 
				 SET RowStatus=0
				 WHERE Guide_Number IN (
				 SELECT lge.Guide_Number FROM DeliveryBackOffice.dbo.DeliverySettlementDetail dsd
				 JOIN DeliveryBackOffice.dbo.DeliveryOrderBySettlement dos ON dos.ID = dsd.ID_DeliveryOrderBySettlement
				 JOIN #listGuidesEnabled lge ON lge.Guide_Number= dsd.Guide_Number
				 ) AND ID_DeliveryOrderBySettlement = (
				 SELECT TOP 1 dos.ID FROM DeliveryBackOffice.dbo.DeliverySettlementDetail dsd
				 JOIN DeliveryBackOffice.dbo.DeliveryOrderBySettlement dos ON dos.ID = dsd.ID_DeliveryOrderBySettlement
				 JOIN #listGuidesEnabled lge ON lge.Guide_Number= dsd.Guide_Number
				 ORDER BY dos.Route_Dispatched DESC
				 )	  

          --INSERT INTO TABLE DELIVERYORDERDETAIL SO WE CAN SETUP A NEW CHECKPOINT FOR TRACKING PURPOSES. 
          INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail(
          [Guide_Serie],
          [Guide_Number],
          [StatusOrderId],
          [UserCreated],
          [DateCreated],
          [DateCreatedInSystem],
          [Observations],
          [Temperature_Celsius],
          [PieceId],
          [RowStatus]
          )
          SELECT
          lge.Guide_Serie,
		  lge.Guide_Number,
          20,
          @TokenCreated,
          GETDATE(),
          GETDATE(),
          NULL,
          NULL,
          NULL,
          1
          FROM #listGuidesEnabled lge;

    END TRY

    BEGIN CATCH

    SET @errorMessage = (SELECT CAST(ERROR_MESSAGE() AS VARCHAR(MAX)) AS ResultMessage);

	  SET @jsonResult = (
						  SELECT STUFF(( 
							  SELECT ',{"IdResult": 500,' 
									  + '"Message":"' + @errorMessage + '"}' 
							  FOR XML PATH(''), TYPE ).value('.', 'VARCHAR(max)'),1,1,'') 
					     )
	ROLLBACK TRANSACTION

    END CATCH;

					IF @@TRANCOUNT > 0 BEGIN

						COMMIT TRANSACTION;
						
					

						set @jsonResult = (
						  SELECT STUFF(( 
							  SELECT ',{"IdResult": 200,' 
									  + '"Message":"Guías Procesadas exitosamente."}' 
							  FOR XML PATH(''), TYPE ).value('.', 'VARCHAR(max)'),1,1,'') 
					     )
				
				
				--- succesfull
		END

    SELECT ('[' + @jsonResult +  ']') jsonResult
			
		END
