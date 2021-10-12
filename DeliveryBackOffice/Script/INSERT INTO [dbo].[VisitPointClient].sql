USE [DeliveryBackOffice]

BEGIN TRAN

--INSERTAR LA PARAMETRIZACION DE LA COURIERAPP COMO NUEVO VISITPOINT
INSERT INTO [dbo].[VisitPointClient]
            ([CodeOfReference],
		     [DescriptionOfClient],
			 [StatusClient],
			 [CountryId],
			 [TokenCreated],
			 [DateCreated])
     VALUES (222825,
			 'COURIERAPP',
			 1,
			 'GT',
			 'SYS-AORTIZ',
			 GETDATE())

--COMMIT


SELECT *
FROM [dbo].[VisitPointClient]