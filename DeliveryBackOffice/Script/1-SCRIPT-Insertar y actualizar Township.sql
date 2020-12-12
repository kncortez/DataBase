
-- Insertar municipios faltantes
INSERT INTO [DeliveryBackOffice].[dbo].[Township]
           ([TownshipName]
           ,[TownshipDescription]
           ,[TownshipLatitud]
           ,[TownshipLongitud]
           ,[PostalCode]
           ,[TownshipStatus]
           ,[IdProvince]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DatedUpdated])
     VALUES
	 ('Comapa','Comapa',NULL,NULL,NULL,1,11,'SYS-CAQUINO',GETDATE(),NULL,NULL)
	  ,('San Jorge','San Jorge',NULL,NULL,NULL,1,22,'SYS-CAQUINO',GETDATE(),NULL,NULL)
	  ,('Estanzuela','Estanzuela',NULL,NULL,NULL,1,22,'SYS-CAQUINO',GETDATE(),NULL,NULL)
	 ,('El Chal','El Chal',NULL,NULL,NULL,1,12,'SYS-CAQUINO',GETDATE(),NULL,NULL)
	 ,('Flores','Flores',NULL,NULL,NULL,1,12,'SYS-CAQUINO',GETDATE(),NULL,NULL)
	 ,('Chicaman','Chicaman',NULL,NULL,NULL,1,14,'SYS-CAQUINO',GETDATE(),NULL,NULL)
	 ,('Uspantan','Uspantan',NULL,NULL,NULL,1,14,'SYS-CAQUINO',GETDATE(),NULL,NULL)
	 ,('Chichicastenango','Chichicastenango',NULL,NULL,NULL,1,14,'SYS-CAQUINO',GETDATE(),NULL,NULL)
	 ,('Union Cantinil','Union Cantinil',NULL,NULL,NULL,1,8,'SYS-CAQUINO',GETDATE(),NULL,NULL)
	 ,('Santa Barbara Huehuetenango','Santa Barbara Huehuetenango',NULL,NULL,NULL,1,8,'SYS-CAQUINO',GETDATE(),NULL,NULL)
	 ,('San Sebastian Coatan','San Sebastian Coatan',NULL,NULL,NULL,1,8,'SYS-CAQUINO',GETDATE(),NULL,NULL)
	 ,('La Libertad Huehuetenango','La Libertad Huehuetenango',NULL,NULL,NULL,1,8,'SYS-CAQUINO',GETDATE(),NULL,NULL)
	 ,('La Democracia Huehuetenango','La Democracia Huehuetenango',NULL,NULL,NULL,1,8,'SYS-CAQUINO',GETDATE(),NULL,NULL)
	 ,('Ayutla','Ayutla',NULL,NULL,NULL,1,17,'SYS-CAQUINO',GETDATE(),NULL,NULL)
	 ,('La Blanca','La Blanca',NULL,NULL,NULL,1,17,'SYS-CAQUINO',GETDATE(),NULL,NULL)
	  ,('San Jose La Maquina','San Jose La Maquina',NULL,NULL,NULL,1,20,'SYS-CAQUINO',GETDATE(),NULL,NULL)
	 ,('Cabrican','Cabrican',NULL,NULL,NULL,1,13,'SYS-CAQUINO',GETDATE(),NULL,NULL)
	 ,('Cajola','Cajola',NULL,NULL,NULL,1,13,'SYS-CAQUINO',GETDATE(),NULL,NULL)
	 ,('San Cristobal Totonicapan','San Cristobal Totonicapan',NULL,NULL,NULL,1,21,'SYS-CAQUINO',GETDATE(),NULL,NULL)
	 ,('Santa Lucia la Reforma','Santa Lucia la Reforma',NULL,NULL,NULL,1,21,'SYS-CAQUINO',GETDATE(),NULL,NULL)
	 ,('San Vicente Pacaya','San Vicente Pacaya',NULL,NULL,NULL,1,6,'SYS-CAQUINO',GETDATE(),NULL,NULL)
     ,('Pochuta','Pochuta',NULL,NULL,NULL,1,3,'SYS-CAQUINO',GETDATE(),NULL,NULL)
	

-- cambio de nombre municipios mal escritos
update Township set TownshipName = 'San Andres Itzapa' where TownshipName = 'San Andres Iztapa' 
update Township set TownshipName = 'Quesada' where TownshipName = 'Quezada' 
update Township set TownshipName = 'Quetzaltepeque' where TownshipName = 'Quezaltepeque' 
update Township set TownshipName = 'San Juan Tecuaco' where IdTownship = 256 and TownshipName = 'Chiquimulilla'
update Township set TownshipName = 'San Lorenzo Suchitepequez' where IdProvince = 20 and TownshipName = 'San Lorenzo'
-- desactivar duplicados
update Township set TownshipStatus =0 where IdProvince = 16 and TownshipName = 'Chinautla'

