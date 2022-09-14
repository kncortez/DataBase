-- INSERTS APO-38
/************************************************************* CatTypeContainer ********************************************************/
INSERT INTO [dbo].[CatTypeContainer]
			([TypeContainerName],
			 [TypeContainerSerie],
			 [TypeContainerDescription],
			 [RowStatus],
			 [TokenCreated],
			 [DateCreated])
		VALUES ('CONTENEDOR GRIS',
				'BOX',
				'CONTENEDOR GRIS PLASTICO 120 * 100 * 63.5',
				1,
				'SYS-JOCHOA',
				SYSDATETIME());

INSERT INTO [dbo].[CatTypeContainer]
			([TypeContainerName],
			 [TypeContainerSerie],
			 [TypeContainerDescription],
			 [RowStatus],
			 [TokenCreated],
			 [DateCreated])
		VALUES ('LINEHAUL *PISO*',
				'LH',
				'LINEHAUL 1327 *PISO*',
				1,
				'SYS-JOCHOA',
				SYSDATETIME());