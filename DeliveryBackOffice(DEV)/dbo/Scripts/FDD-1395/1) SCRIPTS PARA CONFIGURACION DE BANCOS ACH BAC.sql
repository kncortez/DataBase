-- SCRIP PARA INSERTAR NUEVO REGISTRO DE BANCO BANPAIS HN
BEGIN TRY
    BEGIN TRANSACTION;
		--REGISTRO DE BANCOS NUEVOS CUSCATLAN Y CREDIQ
		INSERT INTO dbo.DeliveryBank 
		(Id_bank,Name,Acronym,Description,create_date,Id_status,Id_country,ACHCode,PayingBank)
		VALUES 
		(124,'BANCO CUSCATLAN','CUSCATLAN','BANCO CUSCATLAN',GETDATE(),1,'HN',6,109),
		(136,'BANCO CREDIQ','CREDIQ','BANCO CREDIQ',GETDATE(),1,'HN',52,109)

		--QUITAR BANCOS QUE NO SE USARAN PARA HONDURAS
		UPDATE dbo.DeliveryBank
		SET Id_status = 0
		WHERE Id_bank IN (120, 115, 50, 51,113)

		--ACTUALIZAR BANCO CENTRAL DE HONDURAS
		UPDATE dbo.DeliveryBank
		SET ACHCode = 1,
		PayingBank = 109,
		Acronym = 'BCH'
		WHERE Id_bank = 114

		--ACTUALIZAR BANCO ATLANTIDA S.A. DE C.V.
		UPDATE dbo.DeliveryBank
		SET PayingBank = 53
		WHERE Id_bank = 53

		--ACTUALIZAR BANCO DE OCCIDENTE S.A.
		UPDATE dbo.DeliveryBank
		SET ACHCode = 7,
		PayingBank = 109,
		Name = 'BANCO DE OCCIDENTE S.A.',
		Description = 'BANCO DE OCCIDENTE S.A.',
		Acronym = 'OCCIDENTE'
		WHERE Id_bank = 52

		--ACTUALIZAR BANCO DE HONDURAS
		UPDATE dbo.DeliveryBank
		SET ACHCode = 13,
		PayingBank = 109
		WHERE Id_bank = 111

		--ACTUALIZAR BANCO HONDUREÑO DEL CAFE
		UPDATE dbo.DeliveryBank
		SET ACHCode = 14,
		PayingBank = 109
		WHERE Id_bank = 112

		--ACTUALIZAR BANCO LAFISE
		UPDATE dbo.DeliveryBank
		SET ACHCode = 17,
		PayingBank = 109,
		Description = 'BANCO LAFISE'
		WHERE Id_bank = 116

		--ACTUALIZAR BANCO FINANCIERA CENTROAMERICANA S.A.
		UPDATE dbo.DeliveryBank
		SET ACHCode = 18,
		PayingBank = 109
		WHERE Id_bank = 117

		--ACTUALIZAR BANCO DE AMERICA CENTRAL
		UPDATE dbo.DeliveryBank
		SET ACHCode = 24,
		PayingBank = 109
		WHERE Id_bank = 109

		--ACTUALIZAR BANCO PROMERICA
		UPDATE dbo.DeliveryBank
		SET ACHCode = 25,
		PayingBank = 109
		WHERE Id_bank = 118

		--ACTUALIZAR BANCO FICOHSA
		UPDATE dbo.DeliveryBank
		SET ACHCode = 28,
		PayingBank = 109,
		Name = 'BANCO FICOHSA',
		Description = 'BANCO FICOHSA',
		Acronym = 'FICOHSA'
		WHERE Id_bank = 108

		--ACTUALIZAR BANCO DAVIVIENDA HONDURAS S.A.
		UPDATE dbo.DeliveryBank
		SET PayingBank = 27
		WHERE Id_bank = 27

		--ACTUALIZAR BANCO DE DESARROLLO RURAL
		UPDATE dbo.DeliveryBank
		SET ACHCode = 31,
		PayingBank = 109
		WHERE Id_bank = 110

		--ACTUALIZAR BANCO AZTECA
		UPDATE dbo.DeliveryBank
		SET ACHCode = 32,
		PayingBank = 109,
		Name = 'BANCO AZTECA',
		Description = 'BANCO AZTECA',
		Acronym = 'AZTECA'
		WHERE Id_bank = 17

		--ACTUALIZAR BANCO NACIONAL DE DESARROLLO AGRICOLA
		UPDATE dbo.DeliveryBank
		SET ACHCode = 51,
		PayingBank = 109
		WHERE Id_bank = 119
	COMMIT TRANSACTION 
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
END CATCH