/* =================================================
   SP:        [dbo].[SetImageVisitPoint]
   Propósito: Se almacenara las imagenes de un visitpoint, se actualizara el visitpoint con las columnas Accuracy, Latitude, Longitude.
   Autor:     Hugo Gomez
   Historia:  
   Fecha:     2021-02-16
============================================
=== CHANGELOG ================================
2026-03-06	|	Épica: FDAPI-5776	|	Autor: Erick	|
=========================================== */

CREATE PROCEDURE [dbo].[SetImageVisitPoint]
	-- Add the parameters for the stored procedure here	
	@TblIncidenceLink AS TblIncidenceLink READONLY,
	@CodeOfReference  INT = 0,
	@Accuracy    VARCHAR (200) = '44',
	@Latitude VARCHAR  (200) = '55798797342',
	@Longitude VARCHAR  (200) = '546689',
	@Token VARCHAR (200) = '545656asdf564afd'

	AS BEGIN
		PRINT 'validando token'

		BEGIN 
			PRINT 'token validado'
			SET NOCOUNT ON;
			DECLARE @jsonResult NVARCHAR(MAX) 
				
			-- insertar en tabla temporal posbibles mensajes de respuesta
			IF OBJECT_ID('tempdb.dbo.#responsemessage', 'U') IS NOT NULL DROP TABLE #responsemessage;
				SELECT * INTO #responsemessage FROM (SELECT  200 AS IdResult
					,'Estado  cambiado correctamente' AS Message
					,'OK' AS Id 
				UNION
				SELECT  500 AS IdResult
					,'Error faltal intente de nuevo mas tarde' AS Message
					,'Transac' AS Id 
				)  AS errror
				BEGIN TRANSACTION
					BEGIN TRY
									
						IF (abs(@Latitude) >0 and abs(@Longitude)>0)
							BEGIN
								UPDATE DeliveryBackOffice.dbo.VisitPointClient set Accuracy = @Accuracy, Latitude = @Latitude, Longitude = @Longitude
									WHERE CodeOfReference = @CodeOfReference
							END
							INSERT INTO DeliveryBackOffice.dbo.ImagesByVisitPoint
								(CodeOfReference
									,PathImage
									,RowStatus
									,TokenCreated
									,DateCreated
									,TokenUpdated
									,DateUpdated
								)
							SELECT @CodeOfReference
								,li.PathIncidence
								,1
								,@Token
								,GETDATE()
								,null
								,null
							FROM @TblIncidenceLink li
		
					END TRY
					BEGIN CATCH
						ROLLBACK TRANSACTION
						SELECT ERROR_MESSAGE()

						-- retornar mensaje de error
						SET @jsonResult =(
							SELECT STUFF(( 
								SELECT '"IdResult":' +  convert(VARCHAR,IdResult)    +',' 
									+ '"Message":"' + convert( NVARCHAR(max),ERROR_MESSAGE()) + '"}' 
								FROM #responsemessage WHERE Id ='Invalid'
								FOR XML PATH(''), TYPE
								).value('.', 'varchar(max)'),1,1,''
							) 
						)
					END CATCH;
					IF @@TRANCOUNT > 0 
						BEGIN
							COMMIT TRANSACTION;
							DECLARE @JsonLInk NVARCHAR(max)
								
							SET @JsonLInk = (
								SELECT STUFF(
									(
										SELECT ',{"Url":"' + li.PathIncidence + '"}'
										FROM @TblIncidenceLink li
										FOR XML PATH(''), TYPE
									).value('.', 'varchar(max)'), 1, 1, ''
								)
							);
							SET @jsonResult = (
								SELECT STUFF(
									( 
										SELECT ',"Message":"Guardado exitosamente",' 
											+ '"Path":[' + @JsonLInk + ']' + '}'
										FOR XML PATH(''), TYPE
									).value('.', 'varchar(max)'),1,1,''
								)
							)

						--- succesfull
						END

						-- destruir tablas temporales
						IF OBJECT_ID('tempdb.dbo.#responsemessage', 'U') IS NOT NULL 
							DROP TABLE #responsemessage;

							-- retornar resultado en formato json
							SELECT ('[{' + @jsonResult +  ']') jsonResult								
		END
	END
GO