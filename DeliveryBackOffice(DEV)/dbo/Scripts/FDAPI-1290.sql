-- FDAPI-1290

INSERT INTO [dbo].[ConfigParams]	([Name],
									[Description], 
									[Value],
									[Status],
									[CreateDate])
VALUES								('PymesPackagesGoal',
									'Meta de paquetes para clientes tipo PYMES',
									100,
									1,
									SYSDATETIME());

ALTER TABLE RegisterUser
ADD ChangePassword BIT NULL;

INSERT INTO [dbo].[ConfigParams]	([Name], 
									[Description],
									[Value],
									[Status],
									[CreateDate])
VALUES								('SetTMCustomerAccount', 
									'Nombre de archivo HTML',
									'AccountGenerated.html',
									1, 
									SYSDATETIME());