--SELECT  * FROM dbo.DeliveryBank  WITH (NOLOCK)
--SCRIPT PARA AGREGAR BANCOS DE SV
--ESTOS DATOS SOLO SON DE PRUEBA, SE DEBE DE TENER LA INFORMACIÓN CORRECTA ANTES DE INGRESAR

DECLARE @IdBank INT;

BEGIN TRY
    BEGIN TRANSACTION;

	SET @IdBank = (SELECT TOP 1 Id_bank + 1 FROM dbo.DeliveryBank ORDER BY Id_bank DESC)
    
    INSERT INTO [dbo].[DeliveryBank]
           ([Id_bank]
           ,[Name]
           ,[Acronym]
           ,[Description]
           ,[create_date]
           ,[Id_status]
           ,[Id_country]
           ,[URL_logo]
           ,[CardCode]
           ,[ACHCode]
           ,[PayingBank])
     VALUES
           (@IdBank
           ,'Banco Central de Reserva de El Salvador'
           ,'BCR'
           ,'Banco Central'
           ,GETDATE()
           ,1
           ,'SV'
           ,NULL
           ,NULL
           ,NULL
           ,@IdBank) --Le responde a su propio banco

	SET @IdBank = (SELECT TOP 1 Id_bank + 1 FROM dbo.DeliveryBank ORDER BY Id_bank DESC)
    
    INSERT INTO [dbo].[DeliveryBank]
           ([Id_bank]
           ,[Name]
           ,[Acronym]
           ,[Description]
           ,[create_date]
           ,[Id_status]
           ,[Id_country]
           ,[URL_logo]
           ,[CardCode]
           ,[ACHCode]
           ,[PayingBank])
     VALUES
           (@IdBank
           ,'Banco Cuscatlán de El Salvador, S.A.'
           ,'Banco Cuscatlán'
           ,'Banco Cuscatlán'
           ,GETDATE()
           ,1
           ,'SV'
           ,NULL
           ,NULL
           ,NULL
           ,(@IdBank-1)) --Le responde al banco anterior ingresado
    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
