/*
  INSERCIÓN DE DENOMINACION DE MONEDAS Y BILLETES PARA PAIS EL SALBADOR
*/
BEGIN TRY
    BEGIN TRANSACTION;

    --ID DE LA MONEDA SV
    DECLARE @CurrencySV INT
    SELECT @CurrencySV = Currency_Id FROM DeliveryCurrency WHERE Currency_IdCountry = 'SV' and Currency_Order = 1
    -- MONEDAS
    INSERT INTO CatMoney(CurrencyId, Type, Value, TokenCreated, DateCreated)
    VALUES 
        (@CurrencySV, 'MONEDA', 0.01, 'SYS-CAZURDIA', GETDATE()),
        (@CurrencySV, 'MONEDA', 0.05, 'SYS-CAZURDIA', GETDATE()),
        (@CurrencySV, 'MONEDA', 0.10, 'SYS-CAZURDIA', GETDATE()),
        (@CurrencySV, 'MONEDA', 0.25, 'SYS-CAZURDIA', GETDATE()),
        (@CurrencySV, 'MONEDA', 0.50, 'SYS-CAZURDIA', GETDATE()),
        (@CurrencySV, 'MONEDA', 1.00, 'SYS-CAZURDIA', GETDATE());

    -- BILLETES
    INSERT INTO CatMoney (CurrencyId, Type, Value, TokenCreated, DateCreated)
    VALUES 
        (@CurrencySV, 'BILLETE', 1, 'SYS-CAZURDIA', GETDATE()),
        (@CurrencySV, 'BILLETE', 2, 'SYS-CAZURDIA', GETDATE()),
        (@CurrencySV, 'BILLETE', 5, 'SYS-CAZURDIA', GETDATE()),
        (@CurrencySV, 'BILLETE', 10, 'SYS-CAZURDIA', GETDATE()),
        (@CurrencySV, 'BILLETE', 20, 'SYS-CAZURDIA', GETDATE()),
        (@CurrencySV, 'BILLETE', 50, 'SYS-CAZURDIA', GETDATE()),
        (@CurrencySV, 'BILLETE', 100, 'SYS-CAZURDIA', GETDATE());

    COMMIT TRANSACTION;
    PRINT 'Inserción completada correctamente.';

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error en la inserción: ' + ERROR_MESSAGE();
END CATCH;