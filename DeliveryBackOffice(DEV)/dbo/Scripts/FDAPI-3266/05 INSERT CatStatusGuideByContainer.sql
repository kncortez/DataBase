INSERT INTO CatShipContainerStatus 
VALUES('Liquidado','Contenedor liquidado en proceso de liquidacion de ruta',1,'SYS-BPEDROZA',GETDATE(),'SYS-BPEDROZA',NULL,NULL,NULL)

INSERT INTO [CatStatusGuideByContainer]
VALUES ('Pendiente', 'Indica que la guia esta lista para ser escaneada',1,'SYS-BPEDROZA',GETDATE(),NULL,NULL)

INSERT INTO [CatStatusGuideByContainer]
VALUES ('Escaneada', 'La guia esta preparada para ser liquidada',1,'SYS-BPEDROZA',GETDATE(),NULL,NULL)

