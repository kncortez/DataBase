-- HDB-52

INSERT INTO [dbo].[ConfigParams] (	[Name],
									[Description],
									[Value],
									[Status],
									[CreateDate])
VALUES							(	'SimpliRoutePickupProgrammedConstant',
									'Constante de configuración para tipo de visita de recolecciones programadas en SimpliRoute',
									'recoleccion_con_facturacion',
									1, 
									SYSDATETIME());