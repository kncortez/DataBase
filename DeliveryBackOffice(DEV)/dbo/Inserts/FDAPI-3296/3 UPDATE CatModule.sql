
/**********************ACTUALIZACION DE NOMBRES DE MENU PARA PORTAL INDIVIDUAL*********************************************/
DECLARE @LinkDelivery INT,
		@SendProduct INT,
		@MyProduct INT 


	SET @LinkDelivery = (SELECT ModIdModule FROM CatModule WHERE ModName = 'Link de entrega' )

	SET @SendProduct = (SELECT ModIdModule FROM CatModule WHERE ModName = 'Inventario' )

	SET @MyProduct = (SELECT ModIdModule FROM CatModule WHERE ModName = 'Nuevo Link' )

		
UPDATE CatModule SET ModName = 'Links de entrega' WHERE ModIdModule = @LinkDelivery

UPDATE CatModule SET ModName = 'Enviar un producto', ModMetadata = 'bi bi-send' WHERE ModIdModule = @MyProduct

UPDATE CatModule SET ModName = 'Mis Productos', ModMetadata = 'bi bi-box2' WHERE ModIdModule = @SendProduct 