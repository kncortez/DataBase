-- SCRIP PARA Creaion de parametros de alidaiones COD Antiipado Tarifarios
BEGIN TRY
    BEGIN TRANSACTION;
		UPDATE DeliveryBackOffice.dbo.RateHeader
		SET GuideAmountCOD = 800,
		ReturnPercent = 4,
		IsOldest = 30,
		MinGuidesPerMonth = 25;
	COMMIT TRANSACTION 
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
END CATCH
