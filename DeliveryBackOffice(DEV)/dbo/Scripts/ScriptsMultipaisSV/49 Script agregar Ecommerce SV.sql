--SELECT * FROM DeliveryBackOffice.[dbo].[Ecommerce]

BEGIN TRY
    BEGIN TRANSACTION;
    
    DECLARE @idcustomer int = (SELECT IdCustomer FROM dbo.Customer WHERE name ='FD EXPRESS CENTER SV')


INSERT INTO [dbo].[Ecommerce]
           ([EcomerceName]
           ,[EcommerceDescription]
           ,[IsPaymentGateway]
           ,[IdCountry]
           ,[ApiWSEndPoint]
           ,[ApiWSPort]
           ,[ApiWSResource]
           ,[ApiWSController]
           ,[ApiWSMethod]
           ,[UserKey]
           ,[Passkey]
           ,[SecretKey]
           ,[CertSourceKey]
           ,[EcommerceStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdate]
           ,[DateUpdated]
           ,[IdCustomer])
     VALUES
           (N'http://forzadelivery.com/'
           ,N'Sitio Web Ecommerce Forza Delivery SV'
           ,1
           ,N'SV'
           ,N'forza.systems'
           ,N''
           ,N''
           ,N''
           ,N''
           ,N'SIFDCAPIECOM230920201910'
           ,N''
           ,N'AnvMc+t/0RswIrob9EiU6IjoK6j2wzrr1zpeXAuY80c='
           ,N''
           ,1
           ,N'SYS-WOROZCO'
           ,GETDATE()
           ,NULL
           ,NULL
           ,@idcustomer)
    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
