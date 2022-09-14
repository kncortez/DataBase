-- CatModule - Registro de módulos para sistema Hermes Mobile
INSERT INTO [dbo].[CatModule]
			([ModName],
			 [ModPath],
			 [ModDescription],
			 [ModOrder],
			 [ModVisible],
			 [ModRowStatus],
			 [ModTokenCreated],
			 [ModDateCreated])
		VALUES ('Despacho de linehaul', 
				'linehaul-dispatch', 
				'Módulo de despacho de linehaul en app Mobile', 
				1, 
				1, 
				1, 
				'SYS-JOCHOA', 
				SYSDATETIME());


INSERT INTO [dbo].[CatModule]
			([ModName],
			 [ModPath],
			 [ModDescription],
			 [ModOrder],
			 [ModVisible],
			 [ModRowStatus],
			 [ModTokenCreated],
			 [ModDateCreated])
		VALUES ('Liquidación de linehaul', 
				'linehaul-settlement', 
				'Módulo de liquidación de linehaul en app Hermes Mobile', 
				2, 
				1, 
				1, 
				'SYS-JOCHOA', 
				SYSDATETIME());