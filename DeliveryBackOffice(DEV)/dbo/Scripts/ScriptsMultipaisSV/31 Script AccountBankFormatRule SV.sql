--SELECT  * FROM dbo.AccountBankFormatRule  WITH (NOLOCK)
--SCRIPT PARA AGREGAR CONFIG DE BANCOS SV
--LA INFORMACIÓN ES SOLO DE PRUEBA, SE DEBE DE COLOCAR INFORMACIÓN CORRECTA ANTES DE INSERTAR

DECLARE @IdDeliveryBank INT;
DECLARE @IdCatBankAccountType INT;
DECLARE @IdCountry NVARCHAR(2) = 'SV';

BEGIN TRY
    BEGIN TRANSACTION;

	SET @IdDeliveryBank = (SELECT Id_bank FROM dbo.DeliveryBank WHERE Name = 'Banco Central de Reserva de El Salvador' AND Id_country = @IdCountry)
	SET @IdCatBankAccountType = (SELECT IdBankAccountType FROM dbo.CatBankAccountType WHERE BankAccountType = 'AHORRO' AND IdCountry = @IdCountry)
    
    INSERT INTO [dbo].[AccountBankFormatRule]
           ([DeliveryBankId]
           ,[CatBankAccountTypeId]
           ,[MinimumLength]
           ,[MaximumLength]
           ,[StartsWith]
           ,[Complete]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           (@IdDeliveryBank
           ,@IdCatBankAccountType
           ,28
           ,28
           ,NULL
           ,0
           ,1
           ,'SYS-WOROZCO'
           ,GETDATE()
           ,NULL
           ,NULL)

	SET @IdDeliveryBank = (SELECT Id_bank FROM dbo.DeliveryBank WHERE Name = 'Banco Cuscatlán de El Salvador, S.A.' AND Id_country = @IdCountry)
	SET @IdCatBankAccountType = (SELECT IdBankAccountType FROM dbo.CatBankAccountType WHERE BankAccountType = 'AHORRO' AND IdCountry = @IdCountry)
    
    INSERT INTO [dbo].[AccountBankFormatRule]
           ([DeliveryBankId]
           ,[CatBankAccountTypeId]
           ,[MinimumLength]
           ,[MaximumLength]
           ,[StartsWith]
           ,[Complete]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           (@IdDeliveryBank
           ,@IdCatBankAccountType
           ,20
           ,20
           ,NULL
           ,0
           ,1
           ,'SYS-WOROZCO'
           ,GETDATE()
           ,NULL
           ,NULL)
    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
