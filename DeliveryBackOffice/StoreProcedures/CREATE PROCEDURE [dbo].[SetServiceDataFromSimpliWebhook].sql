USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[SetServiceDataFromSimpliWebhook]    Script Date: 25/08/2021 14:04:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2021-08-25>
-- Description:	< Realiza updates en las tablas de ExtPlatformService y ... >
-- =============================================

CREATE PROCEDURE [dbo].[SetServiceDataFromSimpliWebhook]
	-- DATA PLAN
	@PlanID NVARCHAR(50),
	-- DATA ROUTE
	@RouteID NVARCHAR(50),
	@RouteDriverID INT = 0,
	@RouteDriverName NVARCHAR(200) = '',
	@RouteStartTime DATETIME = NULL,
	@RouteEndTime DATETIME = NULL,
	@RouteComment NVARCHAR(200) = '',
	-- DATA VISIT
	@VisitID INT,
	@VisitType NVARCHAR(50) = NULL,
	@VisitReference NVARCHAR(15),
	@VisitNewStatus NVARCHAR(30),
	@VisitWindowStart NVARCHAR(15) = NULL,
	@VisitWindowEnd NVARCHAR(15) = NULL,
	@VisitCheckin DATETIME = NULL, -- PUEDE QUE FALTE DATO DEL CHECKIN
	@VisitCheckout DATETIME,
	@VisitCheckoutLat DECIMAL(18,15) = 0.0, -- PUEDE QUE POR FALTA DE INTERNET ESTE DATO NO ESTE DISPONIBLE
	@VisitCheckoutLng DECIMAL(18,15) = 0.0, -- PUEDE QUE POR FALTA DE INTERNET ESTE DATO NO ESTE DISPONIBLE
	@VisitCheckoutComment NVARCHAR(200) = '', -- NOTAS MANDADAS DESDE INTEGRACION
	@VisitCheckoutObservation NVARCHAR(200) = '', -- OBSERVACION O INCIDENCIA
	@VisitCheckoutNotes NVARCHAR(200) = '', -- NOTAS DEL COURIERMAN
	-- DATA SERVICE
	@ServicePaymentType INT = NULL,
	@ServicePrice DECIMAL(14,2) = 0,
	@ServiceCoD DECIMAL(14,2) = 0,
	-- DATA INVOICE
	@NIT NVARCHAR(50) = '',
	@InvoiceName NVARCHAR(200) = '',
	@InvoiceAddress NVARCHAR(600) = '',
	@InvoiceEmail NVARCHAR(200) = '',
	-- DATA SIGNATURE AND PICTURES
	@SignatureLink NVARCHAR(200) = '',
	@PictureLinks TblExtPlatTextParameterList READONLY 
AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY
		-- DATOS AUXILIAR 
		DECLARE @GuideSerie NVARCHAR(2) = LEFT(@VisitReference,2);
		DECLARE @GuideNumber INT = CAST( (SUBSTRING(@VisitReference,3,LEN(@VisitReference))) AS INT );
		-- ACTUALIZAR VISITAS DE PLATAFORMA EXTERNA
		UPDATE DeliveryBackOffice.dbo.ExtPlatformService
		SET
			[CheckoutLatitude] = @VisitCheckoutLat,
			[CheckoutLongitude] = @VisitCheckoutLng,
			[Observation] = @VisitCheckoutObservation,
			[ServiceStatus] = @VisitNewStatus,
			[TokenUpdated] = 'SYS-HERMESROUTES' ,
			[DateUpdated] = GETDATE()
		WHERE DeliveryBackOffice.dbo.ExtPlatformService.IdService = @VisitID;
		/* REVISAR SI EXISTEN RUTAS DE IMAGENES 
			IF EXISTS (SELECT 1 FROM @PictureLinks)
			BEGIN
				SELECT 1;
			END
			ELSE
				SELECT 0;
		*/
		-- SI NO INSERTA NADA
		IF @@ROWCOUNT = 0
		BEGIN
			DECLARE @jsonResultNoChange NVARCHAR(MAX) 
			set @jsonResultNoChange =(
								SELECT STUFF(( 
								SELECT ',{"IdResult":400,' 
								+ '"Error":"Ningun dato se actualizo."}' 
								FOR XML PATH(''), TYPE
								).value('.', 'varchar(max)'),1,1,'') )
			select ('[' + @jsonResultNoChange +  ']') jsonResultNoChange 
			ROLLBACK TRANSACTION;
		END
	END TRY
	BEGIN CATCH
		DECLARE @jsonResultError NVARCHAR(MAX) 
		set @jsonResultError =(
							SELECT STUFF(( 
							SELECT '{{"IdResult":500,' 
							+ '"Error":"'+ERROR_MESSAGE()+'"}' 
							FOR XML PATH(''), TYPE
							).value('.', 'varchar(max)'),1,1,'') )
		select ('[' + @jsonResultError +  ']') jsonResultError 
		ROLLBACK TRANSACTION;
	END CATCH
	IF @@TRANCOUNT > 0
	BEGIN
		COMMIT TRANSACTION;
		DECLARE @jsonResult NVARCHAR(MAX) 
		set @jsonResult =(
							SELECT STUFF(( 
							SELECT ',{"IdResult":200,' 
							+ '"Success":"Exito registrando datos de webhook."}' 
							FOR XML PATH(''), TYPE
							).value('.', 'varchar(max)'),1,1,'') )
		select ('[' + @jsonResult +  ']') jsonResult 
	END
END
