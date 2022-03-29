USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[CatArticle] ([ArtIdTypeArticle]
, [ArtName]
, [ArtShowDefault]
, [ArtRowStatus]
, [ArtTokenCreated]
, [ArtDateCreated]
, [ArtTokenUpdated]
, [ArtDateUpdated]
, [ArtHeight]
, [ArtWidth]
, [ArtLength]
, [ArtMassWeight])
	VALUES ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Mueble'),'Alacena Doble Puertas','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Mueble'),'Amueblado Comedor 4 Personas','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Mueble'),'Amueblado De 4 Pax','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Mueble'),'Amueblado De 6 Pax','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Mueble'),'Amueblado De Sala','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Mueble'),'Armario','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Bicicleta'),'Bicicleta Grande','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Bicicleta'),'Bicicleta Pequeña','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Mueble'),'Butaca','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Mueble'),'Cabecera Con Mesa De Noche','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Mueble'),'Cabecera Plana Matrimonial','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Electrodomésticos'),'Caja De Aire Acondicionado','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Repuestos Carro'),'Cajas De Vehiculos','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Cama'),'Cama Semi-Matrimonial','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Refrigeración'),'Camaras y Enfriadores y Freezer','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Mueble'),'Camilla','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Repuestos Carro'),'Capos','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Mueble'),'Centro De Entretenimiento','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Jardín'),'Chapeadora','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Herramienta'),'Compresores 50 Lts','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Refrigeración'),'Congelador De 8 A 15 Pies','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Refrigeración'),'Congelador Mediano','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Refrigeración'),'Congelador Pequeño','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Mueble'),'Cuna Con Gavetas','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Mueble'),'Cunas','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Herramienta'),'Escaleras Menos De 5Mts','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Escritorio'),'Escritorios Desarmados','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Escritorio'),'Escritorios Gerenciales','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Electrodomésticos'),'Estufas Grandes','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Electrodomésticos'),'Estufas Industriales','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Fotocopiadora'),'Fotocopiadoras Grandes','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Fotocopiadora'),'Fotocopiadoras Medianas','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Mueble'),'Gavetero','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Electrodomésticos'),'Horno Microhonda','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Baños'),'Jacuzzi, Tinas','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Electrodomésticos'),'Lavadora-Secadora (Combo)','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Cama'),'Litera Imperial 2 Piezas','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Repuestos Carro'),'Llantas De Tractor','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Repuestos Carro'),'Loderas','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Electrodomésticos'),'Maquina De Coser','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Deporte'),'Mesas De Futillo','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Mueble'),'Mostradores (Vidrio,Madera)','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Motocicleta'),'Motocicletas (4 Llantas)','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Motocicleta'),'Motocicletas 2 Ruedas','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Repuestos Carro'),'Motores De Vehiculos Livianos','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Electrodomésticos'),'Oasis','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Herramienta'),'Plantas Generadoras','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Construcción'),'Puertas','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Recámara'),'Recamara 5 Pz','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Recámara'),'Recamara 6 Piezas','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Recámara'),'Recamara 8 Pz','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Refrigeración'),'Refrigeradoras 14 - 17','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Refrigeración'),'Refrigeradoras 21 En Adelante','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Refrigeración'),'Refrigeradoras 9 - 12','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Mueble'),'Roperos','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Construcción'),'Rotulos','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Silla Ruedas'),'Silla Ruedas (Caja)','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Oficina'),'Silla Secretarial Basica C/ Negro 1576-B','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Oficina'),'Sillon Extensible, Reclinable y Butaca M','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Mueble'),'Trinchante','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Televisor'),'TV Led 24','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Televisor'),'TV Led 50','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Televisor'),'TVS Plasma 32','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Televisor'),'TVS Plasma 60','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Electrodomésticos'),'Ventilador D/Pedestal Fs1810 Parker Metr','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45),
    ((SELECT TarId FROM CatTypeArticle WHERE TarName = 'Repuestos Carro'),'Wind Shield','FALSE','TRUE','SYS-OMORALES',GETDATE(),NULL,NULL,30,30,30,45)