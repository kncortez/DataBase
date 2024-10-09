-- SCRIP PARA INSERTAR DATOS DE IMAGENES POR PAIS EN TABLA PARA CAROSUSEL DE IMAGENES MOVIL APP
BEGIN TRY
    BEGIN TRANSACTION;
		INSERT INTO DeliveryBackOffice.dbo.MovilAppCarouselImage 
		(SDImageURL,MDImageURL,LDImageURL,ImageOrder,RowStatus,IdCountry,TokenCreated,DateCreated) 
		VALUES
		('https://forzadelivery.com/images/MovilApp/slider01-1280-720.jpg','https://forzadelivery.com/images/MovilApp/slider01-1920-1080.jpg','https://forzadelivery.com/images/MovilApp/slider01-2560-1440.jpg',1,1,'GT','ORODRIGUEZ-SYS',GETDATE()),
		('https://forzadelivery.com/images/MovilApp/slider02-1280-720.jpg','https://forzadelivery.com/images/MovilApp/slider02-1920-1080.jpg','https://forzadelivery.com/images/MovilApp/slider02-2560-1440.jpg',2,1,'GT','ORODRIGUEZ-SYS',GETDATE()),
		('https://forzadelivery.com/images/MovilApp/slider03-1280-720.jpg','https://forzadelivery.com/images/MovilApp/slider03-1920-1080.jpg','https://forzadelivery.com/images/MovilApp/slider03-2560-1440.jpg',3,1,'GT','ORODRIGUEZ-SYS',GETDATE()),
		('https://forzadelivery.com/images/MovilApp/slider01-1280-720.jpg','https://forzadelivery.com/images/MovilApp/slider01-1920-1080.jpg','https://forzadelivery.com/images/MovilApp/slider01-2560-1440.jpg',1,1,'HN','ORODRIGUEZ-SYS',GETDATE()),
		('https://forzadelivery.com/images/MovilApp/slider02-1280-720.jpg','https://forzadelivery.com/images/MovilApp/slider02-1920-1080.jpg','https://forzadelivery.com/images/MovilApp/slider02-2560-1440.jpg',2,1,'HN','ORODRIGUEZ-SYS',GETDATE()),
		('https://forzadelivery.com/images/MovilApp/slider03-1280-720.jpg','https://forzadelivery.com/images/MovilApp/slider03-1920-1080.jpg','https://forzadelivery.com/images/MovilApp/slider03-2560-1440.jpg',3,1,'HN','ORODRIGUEZ-SYS',GETDATE())
	COMMIT TRANSACTION 
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
END CATCH