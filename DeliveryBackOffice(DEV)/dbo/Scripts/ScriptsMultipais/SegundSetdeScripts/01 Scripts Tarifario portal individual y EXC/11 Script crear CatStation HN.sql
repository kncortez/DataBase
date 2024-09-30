BEGIN TRY
    BEGIN TRANSACTION;
	--CREAMOS ESTACION PARA HONDURAS

	DECLARE @IdCatStatusType INT;
	DECLARE @IdCustomer INT;
	DECLARE @CodeOfReference INT;

	SELECT @IdCatStatusType = IdCatStatusType FROM DeliveryBackOffice.dbo.CatStatusType WITH(NOLOCK)
	WHERE StatusType = 'Externo'

	SELECT @IdCustomer = IdCustomer FROM DeliveryBackOffice.dbo.Customer WITH(NOLOCK)
	WHERE Name = 'FD EXPRESS CENTER HN' AND Description = 'FD EXPRESS CENTER HN'
	AND RowSatus = 1 AND CountryID = 'HN'

	SELECT @CodeOfReference = CodeOfReference FROM DeliveryBackOffice.dbo.VisitPointClient WITH(NOLOCK)
	WHERE CustomerID = @IdCustomer AND DescriptionOfClient = 'FD EXC HN 1'

	INSERT INTO CatStation VALUES ('FD EXC HN 1', 'HN',@IdCatStatusType,
	NULL,@CodeOfReference,1,'SYS-WOROZCO',GETDATE(),NULL,NULL)

	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
