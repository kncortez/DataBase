-- APO-38

-- Table CatTypeContainer
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


-- Table Container
INSERT INTO [dbo].[Container]
			([CatTypeContainerId],
			 [ContainerNumber],
			 [ContainerDescription],
			 [RowStatus],
			 [TokenCreated],
			 [DateCreated])
		VALUES ((SELECT [dbo].[CatTypeContainer].[IdCatTypeContainer]
				 FROM [dbo].[CatTypeContainer]
				 WHERE [CatTypeContainer].[TypeContainerSerie] = 'BOX'),
				'00001',
				'BOX00001',
				1,
				'SYS-JOCHOA',
				SYSDATETIME());

INSERT INTO [dbo].[Container]
			([CatTypeContainerId],
			 [ContainerNumber],
			 [ContainerDescription],
			 [RowStatus],
			 [TokenCreated],
			 [DateCreated])
		VALUES ((SELECT [dbo].[CatTypeContainer].[IdCatTypeContainer]
				 FROM [dbo].[CatTypeContainer]
				 WHERE [CatTypeContainer].[TypeContainerSerie] = 'BOX'),
				'00002',
				'BOX00002',
				1,
				'SYS-JOCHOA',
				SYSDATETIME());

INSERT INTO [dbo].[Container]
			([CatTypeContainerId],
			 [ContainerNumber],
			 [ContainerDescription],
			 [RowStatus],
			 [TokenCreated],
			 [DateCreated])
		VALUES ((SELECT [dbo].[CatTypeContainer].[IdCatTypeContainer]
				 FROM [dbo].[CatTypeContainer]
				 WHERE [CatTypeContainer].[TypeContainerSerie] = 'LH'),
				'00001',
				'LH00001',
				1,
				'SYS-JOCHOA',
				SYSDATETIME());

