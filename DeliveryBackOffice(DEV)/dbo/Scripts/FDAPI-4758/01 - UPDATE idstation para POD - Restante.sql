--ACTUALIZA IDSTATION PARA POD PARA PROCESOS ADMINISTRATIVOS

DECLARE @RowsAffected INT = 1, @Contador int =0;

WHILE (@RowsAffected > 0 )
BEGIN
    BEGIN TRY
        BEGIN TRAN;

	   UPDATE TOP (10000) DOD
		  SET DOD.StationId = HL.IdStation
	   FROM DeliveryOrderDetail DOD WITH(NOLOCK)
	   INNER JOIN DeliverySettlementDetail DSD WITH (NOLOCK)
	   ON DOD.Guide_Serie = DSD.Guide_Serie
	   AND DOD.Guide_Number = DSD.Guide_Number
	   INNER JOIN DeliveryOrderBySettlement DOS WITH (NOLOCK)
	   ON DOS.ID = DSD.ID_DeliveryOrderBySettlement
	   INNER JOIN SenderReceiver SR WITH (NOLOCK)
	   ON DOS.ID_Courier = SR.ID 
	   INNER JOIN HubLogistics HL WITH (NOLOCK)
	   ON SR.HubLogisticId = HL.IdHubLogistic 
	   where DOD.StationId is null
	     AND HL.IdStation IS NOT NULL
		 AND DOD.StatusOrderId NOT IN (2,11,3,4,5,8,14,32,45,50);
       
	   SET @RowsAffected = @@ROWCOUNT;
	    
	   COMMIT TRAN;

        SET @Contador += 1;
        PRINT('LOTE ' + CONVERT(NVARCHAR(10), @Contador) 
              + ' actualizado. Filas: ' + CONVERT(NVARCHAR(10), @RowsAffected));
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;
        DECLARE 
            @ErrorMessage NVARCHAR(4000),
            @ErrorSeverity INT,
            @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        PRINT('ERROR EN LOTE ' + CONVERT(NVARCHAR(10), @Contador));
        PRINT(@ErrorMessage);

        -- Detiene el proceso ante error
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
        BREAK;
    END CATCH;
END;