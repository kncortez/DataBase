CREATE PROCEDURE Support_ActivateAndBlockCorporateUser
    @RowStatus INT,  -- 1 = Activado, 0 = Bloqueado
    @Customer INT
AS
BEGIN
    -- Actualizamos el estado
    UPDATE Account
    SET AccRowStatus = @RowStatus
    WHERE IdCustomer = @Customer;

    -- Mensaje según el valor
    IF @RowStatus = 1
        PRINT 'Usuario activado';
    ELSE IF @RowStatus = 0
        PRINT 'Usuario bloqueado';
    ELSE
        PRINT 'Valor de RowStatus inválido';
END