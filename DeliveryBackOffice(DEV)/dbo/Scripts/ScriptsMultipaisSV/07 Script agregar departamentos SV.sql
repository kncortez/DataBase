SELECT * FROM DeliveryBackOffice.dbo.Province WITH(NOLOCK) --Departamentos

BEGIN TRY
    BEGIN TRANSACTION;

INSERT INTO [dbo].[Province]([ProvinceName],[ProvinceDescription],[ProvinceStatus],[ProvinceLatitud],[ProvinceLongitud],[PostalCode],[IdCountry],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[ProvinceAbbreviation],[LocalCode])VALUES('Ahuachapán','Ahuachapán',1,NULL,NULL,NULL,'SV','SYS-WOROZCO',GETDATE(),NULL,NULL,'AHU','01')
INSERT INTO [dbo].[Province]([ProvinceName],[ProvinceDescription],[ProvinceStatus],[ProvinceLatitud],[ProvinceLongitud],[PostalCode],[IdCountry],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[ProvinceAbbreviation],[LocalCode])VALUES('Cabañas','Cabañas',1,NULL,NULL,NULL,'SV','SYS-WOROZCO',GETDATE(),NULL,NULL,'CAB','02')
INSERT INTO [dbo].[Province]([ProvinceName],[ProvinceDescription],[ProvinceStatus],[ProvinceLatitud],[ProvinceLongitud],[PostalCode],[IdCountry],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[ProvinceAbbreviation],[LocalCode])VALUES('Chalatenango','Chalatenango',1,NULL,NULL,NULL,'SV','SYS-WOROZCO',GETDATE(),NULL,NULL,'CHA','03')
INSERT INTO [dbo].[Province]([ProvinceName],[ProvinceDescription],[ProvinceStatus],[ProvinceLatitud],[ProvinceLongitud],[PostalCode],[IdCountry],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[ProvinceAbbreviation],[LocalCode])VALUES('Cuscatlán','Cuscatlán',1,NULL,NULL,NULL,'SV','SYS-WOROZCO',GETDATE(),NULL,NULL,'CUS','04')
INSERT INTO [dbo].[Province]([ProvinceName],[ProvinceDescription],[ProvinceStatus],[ProvinceLatitud],[ProvinceLongitud],[PostalCode],[IdCountry],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[ProvinceAbbreviation],[LocalCode])VALUES('La Libertad','La Libertad',1,NULL,NULL,NULL,'SV','SYS-WOROZCO',GETDATE(),NULL,NULL,'LIB','05')
INSERT INTO [dbo].[Province]([ProvinceName],[ProvinceDescription],[ProvinceStatus],[ProvinceLatitud],[ProvinceLongitud],[PostalCode],[IdCountry],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[ProvinceAbbreviation],[LocalCode])VALUES('La Paz','La Paz',1,NULL,NULL,NULL,'SV','SYS-WOROZCO',GETDATE(),NULL,NULL,'PAZ','06')
INSERT INTO [dbo].[Province]([ProvinceName],[ProvinceDescription],[ProvinceStatus],[ProvinceLatitud],[ProvinceLongitud],[PostalCode],[IdCountry],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[ProvinceAbbreviation],[LocalCode])VALUES('La Unión','La Unión',1,NULL,NULL,NULL,'SV','SYS-WOROZCO',GETDATE(),NULL,NULL,'UNI','07')
INSERT INTO [dbo].[Province]([ProvinceName],[ProvinceDescription],[ProvinceStatus],[ProvinceLatitud],[ProvinceLongitud],[PostalCode],[IdCountry],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[ProvinceAbbreviation],[LocalCode])VALUES('Morazán','Morazán',1,NULL,NULL,NULL,'SV','SYS-WOROZCO',GETDATE(),NULL,NULL,'MOR','08')
INSERT INTO [dbo].[Province]([ProvinceName],[ProvinceDescription],[ProvinceStatus],[ProvinceLatitud],[ProvinceLongitud],[PostalCode],[IdCountry],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[ProvinceAbbreviation],[LocalCode])VALUES('San Miguel','San Miguel',1,NULL,NULL,NULL,'SV','SYS-WOROZCO',GETDATE(),NULL,NULL,'MIG','09')
INSERT INTO [dbo].[Province]([ProvinceName],[ProvinceDescription],[ProvinceStatus],[ProvinceLatitud],[ProvinceLongitud],[PostalCode],[IdCountry],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[ProvinceAbbreviation],[LocalCode])VALUES('San Salvador','San Salvador',1,NULL,NULL,NULL,'SV','SYS-WOROZCO',GETDATE(),NULL,NULL,'SAL','10')
INSERT INTO [dbo].[Province]([ProvinceName],[ProvinceDescription],[ProvinceStatus],[ProvinceLatitud],[ProvinceLongitud],[PostalCode],[IdCountry],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[ProvinceAbbreviation],[LocalCode])VALUES('San Vicente','San Vicente',1,NULL,NULL,NULL,'SV','SYS-WOROZCO',GETDATE(),NULL,NULL,'VIC','11')
INSERT INTO [dbo].[Province]([ProvinceName],[ProvinceDescription],[ProvinceStatus],[ProvinceLatitud],[ProvinceLongitud],[PostalCode],[IdCountry],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[ProvinceAbbreviation],[LocalCode])VALUES('Santa Ana','Santa Ana',1,NULL,NULL,NULL,'SV','SYS-WOROZCO',GETDATE(),NULL,NULL,'ANA','12')
INSERT INTO [dbo].[Province]([ProvinceName],[ProvinceDescription],[ProvinceStatus],[ProvinceLatitud],[ProvinceLongitud],[PostalCode],[IdCountry],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[ProvinceAbbreviation],[LocalCode])VALUES('Sonsonate','Sonsonate',1,NULL,NULL,NULL,'SV','SYS-WOROZCO',GETDATE(),NULL,NULL,'SON','13')
INSERT INTO [dbo].[Province]([ProvinceName],[ProvinceDescription],[ProvinceStatus],[ProvinceLatitud],[ProvinceLongitud],[PostalCode],[IdCountry],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated],[ProvinceAbbreviation],[LocalCode])VALUES('Usulután','Usulután',1,NULL,NULL,NULL,'SV','SYS-WOROZCO',GETDATE(),NULL,NULL,'USU','14')


 COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;