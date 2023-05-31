-- SCRIPTS - FDAPI-1397

INSERT INTO [dbo].[ConfigParams](	[Name],
									[Description],
									[Value],
									[Status],
									[CreateDate])
VALUES							(	'SimpliRouteProgrammedPickupActived',
									'Bandera para indicar que el servicio de recolecciones programadas si se debe enviar a Simpli Route',
									'1',
									1,
									SYSDATETIME());


INSERT INTO [dbo].[ConfigParams](	[Name],
									[Description],
									[Value],
									[Status],
									[CreateDate])
VALUES							(	'SimpliRouteDeliveriesActived',
									'Bandera para indicar que el servicio de entregas si se debe enviar a Simpli Route',
									'1',
									1,
									SYSDATETIME());