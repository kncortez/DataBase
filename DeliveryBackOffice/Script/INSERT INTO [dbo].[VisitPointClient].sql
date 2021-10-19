USE [DeliveryBackOffice]

--INSERTAR LA PARAMETRIZACION DE LA COURIERAPP COMO NUEVO VISITPOINT
DECLARE @CodeOfReference INT = 3000;
DECLARE @DescriptionOfClient NVARCHAR(100) = 'COURIERAPP';
DECLARE @StatusClient BIT = 'TRUE';
DECLARE @CountryId NVARCHAR(2) = 'GT';
DECLARE @TokenCreated NVARCHAR(50) = 'SYS-AORTIZ';
DECLARE @DateCreated DATETIME = GETDATE();

INSERT INTO [dbo].[VisitPointClient]
            ([CodeOfReference],
		     [DescriptionOfClient],
			 [StatusClient],
			 [CountryId],
			 [TokenCreated],
			 [DateCreated])
     VALUES (@CodeOfReference,
			 @DescriptionOfClient,
			 @StatusClient,
			 @CountryId,
			 @TokenCreated,
			 @DateCreated)
