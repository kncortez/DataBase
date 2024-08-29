--- SE PONEN NO VISIBLES MODULOS DE ENTREGAS
----UTILIZADOS EN PORTAL INTERNO
	UPDATE CatModule
	SET ModVisible = 0
	WHERE ModIdModule = 79 -- ModName: Entregas

	UPDATE CatModule
	SET ModVisible = 0
	WHERE ModIdModule = 80 -- ModName: Monitoreo de visitas fallidas

	UPDATE CatModule
	SET ModVisible = 0
	WHERE ModIdModule = 81 -- ModName: Dashboard de visitas fallidas

	UPDATE CatModule
	SET ModVisible = 0
	WHERE ModIdModule = 119 -- ModName: Seguimiento de incidencias