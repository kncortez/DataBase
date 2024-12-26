-- SCRIP PARA Creaion de parametros de alidaiones COD Antiipado Tarifarios
BEGIN TRY
    BEGIN TRANSACTION;
		ALTER TABLE DeliveryBackOffice.dbo.RateHeader
		ADD GuideAmountCOD DECIMAL(18,2),
		ReturnPercent INT,
		IsOldest INT,
		MinGuidesPerMonth INT;

		--UPDATE DeliveryBackOffice.dbo.RateHeader
		--SET GuideAmountCOD = 800,
		--ReturnPercent = 4,
		--IsOldest = 30,
		--MinGuidesPerMonth = 25
		--WHERE IdCountry = 'GT';

		--UPDATE DeliveryBackOffice.dbo.RateHeader
		--SET GuideAmountCOD = 2400,
		--ReturnPercent = 4,
		--IsOldest = 30,
		--MinGuidesPerMonth = 25
		--WHERE IdCountry = 'HN';
	COMMIT TRANSACTION 
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
END CATCH
