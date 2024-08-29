
--SCRIPT PARA AGREGAR NUEVA COLUMNA DE PAÍS EN CatDeliveryOptions

ALTER TABLE DeliveryBackOffice.dbo.CatDeliveryOptions
ADD IdCountry VARCHAR(2);

ALTER TABLE DeliveryBackOffice.dbo.CatDeliveryOptions
ADD CONSTRAINT FK_CatDeliveryOptions_CatCountry FOREIGN KEY (IdCountry)
REFERENCES DeliveryBackOffice.dbo.CatCountry(IdCountry);


--SCRIPT AGREGAR VALORES A CatDeliveryOptions DE HN

SELECT * FROM DeliveryBackOffice.dbo.CatDeliveryOptions

--UPDATE DeliveryBackOffice.dbo.CatDeliveryOptions
--SET IdCountry = 'GT' --ESTO ANTES DE INSERTAR LOS VALORES DE HN

INSERT INTO [dbo].[CatDeliveryOptions]
           ([Name]
           ,[Description]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated]
           ,[IdCountry])
     VALUES
           ('Casa'
           ,'Opción de entrega casa'
           ,1
           ,'SYS-WOROZCO'
           ,GETDATE()
           ,NULL
           ,NULL
           ,'HN')

INSERT INTO [dbo].[CatDeliveryOptions]
           ([Name]
           ,[Description]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated]
           ,[IdCountry])
     VALUES
           ('Oficina'
           ,'Opción de entrega oficina'
           ,1
           ,'SYS-WOROZCO'
           ,GETDATE()
           ,NULL
           ,NULL
           ,'HN')

INSERT INTO [dbo].[CatDeliveryOptions]
           ([Name]
           ,[Description]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated]
           ,[IdCountry])
     VALUES
           ('Express Center'
           ,'Opción de entrega Express Center'
           ,1
           ,'SYS-WOROZCO'
           ,GETDATE()
           ,NULL
           ,NULL
           ,'HN')

INSERT INTO [dbo].[CatDeliveryOptions]
           ([Name]
           ,[Description]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated]
           ,[IdCountry])
     VALUES
           ('Smart Locker'
           ,'Opción de entrega Smart Locker'
           ,1
           ,'SYS-WOROZCO'
           ,GETDATE()
           ,NULL
           ,NULL
           ,'HN')