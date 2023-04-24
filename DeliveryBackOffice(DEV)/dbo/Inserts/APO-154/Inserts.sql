-- APO-154
INSERT INTO [dbo].[CatTypeContainer] (	[TypeContainerName],
										[TypeContainerSerie],
										[TypeContainerDescription],
										[AllowStopOver],
										[RowStatus],
										[TokenCreated],
										[DateCreated])
VALUES									('CONTENEDOR VIRTUAL',
										'VBX',
										'CONTENEDOR VIRTUAL',
										0, 
										1,
										'SYS-JOCHOA',
										SYSDATETIME());

INSERT INTO [dbo].[Container](	[CatTypeContainerId],
								[ContainerNumber],
								[ContainerDescription],
								[RowStatus], 
								[TokenCreated], 
								[DateCreated])
VALUES						(	(SELECT [CTC].[IdCatTypeContainer] FROM [dbo].[CatTypeContainer] CTC WHERE [CTC].TypeContainerSerie = 'VBX'),
								'00001',
								'VBX00001',
								1,
								'SYS-JOCHOA',
								SYSDATETIME());