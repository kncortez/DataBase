-- SCRIP PARA Creaion de parametros de alidaiones COD Antiipado Tarifarios
BEGIN TRY
    BEGIN TRANSACTION;
		ALTER TABLE DeliveryBackOffice.dbo.RateHeader
		ADD GuideAmountCOD DECIMAL(18,2) DEFAULT 800,
		ReturnPercent INT DEFAULT 4,
		IsOldest INT DEFAULT 30,
		MinGuidesPerMonth INT DEFAULT 25;

		--UPDATE DeliveryBackOffice.dbo.RateHeader
		--SET GuideAmountCOD = 800,
		--ReturnPercent = 4,
		--IsOldest = 30,
		--MinGuidesPerMonth = 25;
	COMMIT TRANSACTION 
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
END CATCH
