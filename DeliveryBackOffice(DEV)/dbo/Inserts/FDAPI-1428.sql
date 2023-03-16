-- FDAPI-1428

INSERT INTO IncidenceDynamicInput(	[FieldName],
									[FieldType],
									[IsEditable],
									[CatTypeIncidenceId],
									[RowStatus],
									[TokenCreated],
									[DateCreated])
VALUES							(	'ServiceAddress',
									'String',
									1,
									(SELECT [CTI].[IdIncidenceType] FROM [dbo].[CatTypeIncidence] CTI WHERE [CTI].[NameIncidence] = 'No hay nadie en destino'),
									1,
									'SYS-JOCHOA',
									SYSDATETIME());

INSERT INTO IncidenceDynamicInput(	[FieldName],
									[FieldType],
									[IsEditable],
									[CatTypeIncidenceId],
									[RowStatus],
									[TokenCreated],
									[DateCreated])
VALUES							(	'ServicePhone',
									'String',
									1,
									(SELECT [CTI].[IdIncidenceType] FROM [dbo].[CatTypeIncidence] CTI WHERE [CTI].[NameIncidence] = 'No hay nadie en destino'),
									1,
									'SYS-JOCHOA',
									SYSDATETIME());

INSERT INTO IncidenceDynamicInput(	[FieldName],
									[FieldType],
									[IsEditable],
									[CatTypeIncidenceId],
									[RowStatus],
									[TokenCreated],
									[DateCreated])
VALUES							(	'ServiceDate',
									'DateTime',
									1,
									(SELECT [CTI].[IdIncidenceType] FROM [dbo].[CatTypeIncidence] CTI WHERE [CTI].[NameIncidence] = 'No hay nadie en destino'),
									1,
									'SYS-JOCHOA',
									SYSDATETIME());

INSERT INTO [dbo].[IncidenceDynamicQuestion] (	[QuestionTrue],
												[QuestionFalse],
												[SpecialInstructions],
												[CatTypeIncidenceId],
												[RowStatus],
												[TokenCreated],
												[DateCreated])
VALUES										(	'Efectivamente no había nadie en casa',
												'Yo estaba en el destino',
												'',
												(SELECT [CTI].[IdIncidenceType] FROM [dbo].[CatTypeIncidence] CTI WHERE [CTI].[NameIncidence] = 'No hay nadie en destino'),
												1,
												'SYS-JOCHOA',
												SYSDATETIME());