-- =============================================
-- Author:		<Eduardo, López>
-- Create date: <2023-02-23>
-- Description:	<Registrar microzonas y puntos cargadas desde modulo Microzonas BackOffice>
-- =============================================

CREATE PROCEDURE SetMicroZones
@TblMicroZones AS TblMicroZones READONLY,
@Token AS VARCHAR(50)

AS
BEGIN

		 BEGIN TRANSACTION; 
		   BEGIN TRY

			-- Quitar todos los puntos de geocercas "No perdurables"
			UPDATE 
				pt1
			SET 
				pt1.RowStatus = 0
			FROM 
				dbo.Point pt1 WITH (NOLOCK)
				INNER JOIN 
					GeofencePoint gfp1 WITH (NOLOCK)
					ON 
						pt1.IdPoint = gfp1.IdPoint
				 INNER JOIN 
					Geofence gfce1 WITH (NOLOCK)
					ON 
						gfp1.IdGeofence = gfce1.IdGeofence
				WHERE pt1.RowStatus = 1 AND gfp1.RowStatus = 1 AND gfce1.RowStatus = 1 AND gfce1.UpdateFlag = 0
	
			-- Quitar la asociación de puntos de geocercas "No perdurables"
			UPDATE 
				gpt
			SET 
				gpt.RowStatus = 0
			FROM 
				dbo.GeofencePoint gpt WITH (NOLOCK)
				INNER JOIN 
					Geofence gfce WITH (NOLOCK)
					ON 
						gpt.IdGeofence = gfce.IdGeofence
				WHERE gpt.RowStatus = 1 AND gfce.RowStatus = 1 AND gfce.UpdateFlag = 0

			-- Quitar geocercas "No perdurables"
			UPDATE 
				gfc
			SET 
				gfc.RowStatus = 0
			FROM 
				dbo.Geofence gfc WITH (NOLOCK)
				WHERE gfc.RowStatus = 1 AND gfc.UpdateFlag = 0

			-- Ingresar nuevas microzonas
			 INSERT INTO dbo.Geofence
						(
						 CountryId
						 ,GeofenceDescription
						 ,RowStatus
						 ,TokenCreated
						 ,DateCreated
						)
						SELECT DISTINCT
						'GT'
						,[tbm].[NameCol]
						,1
						,@Token
						,GETDATE()
						FROM @TblMicroZones tbm 

				-- Ingresar nuevos puntos de microzonas
				INSERT INTO dbo.Point
						(
						 PointDescription
						,PointLatitude
						,PointLongitude
						,RowStatus
						,TokenCreated
						,DateCreated
						,TokenUpdated
						,DateUpdated
						)
						SELECT
						CONCAT(tbmz.[NameCol],'-',[tbmz].[NumCol]) 	
						,(SELECT CAST ((SUBSTRING(tbmz.MicroZones, CHARINDEX(' ',tbmz.MicroZones)+1, CHARINDEX(' ',tbmz.MicroZones))) AS DECIMAL(15,7)))
						,(SELECT CAST ((SUBSTRING(tbmz.MicroZones, 1, CHARINDEX(' ',tbmz.MicroZones))) AS DECIMAL(15,7)))
						,1
						,@Token
						,GETDATE()
						,null
						,null
						FROM @TblMicroZones tbmz
						ORDER BY
							[tbmz].[NameCol] ASC,
							[tbmz].[NumCol] ASC

					-- Relacionar nuevos puntos de microzonas con geocercas
					INSERT INTO dbo.GeofencePoint
								(
								IdGeofence
								,IdPoint
								,GeofencePointOrder
								,RowStatus
								,TokenCreated
								,DateCreated
								)
								SELECT
									gf.IdGeofence
									,pt.IdPoint
									,tb.NumCol
									,1
									,@Token
									,GETDATE()
								FROM 
									Geofence gf WITH (NOLOCK)
									INNER JOIN 
										@TblMicroZones tb
										ON gf.GeofenceDescription = tb.[NameCol]
									INNER JOIN 
										Point pt WITH (NOLOCK)
									ON 
										pt.PointDescription = CONCAT(tb.[NameCol],'-',tb.[NumCol])
										AND 
										pt.PointFlag = 0
								WHERE gf.UpdateFlag = 0 AND gf.RowStatus = 1 AND pt.RowStatus = 1
								GROUP BY pt.IdPoint,pt.PointDescription,gf.IdGeofence, tb.NameMicroZones, tb.NumCol, tb.NameCol

						-- Finalizar poligono reingresando primer punto de microzona
						INSERT INTO dbo.GeofencePoint
								(
								IdGeofence
								,IdPoint
								,GeofencePointOrder
								,RowStatus
								,TokenCreated
								,DateCreated
								)
								SELECT
									gf.IdGeofence
									,pt.IdPoint
									,
									(
										SELECT 
											TOP (1) 
												MAX(GP.[GeofencePointOrder]) + 1 
										FROM 
											[dbo].[GeofencePoint] GP  WITH(NOLOCK) 
										WHERE
											[GP].[IdGeofence] = [gf].[IdGeofence]
									)
									,1
									,@Token
									,GETDATE()
								FROM 
									Geofence gf WITH (NOLOCK)
									INNER JOIN 
										@TblMicroZones tb
										ON gf.GeofenceDescription = tb.[NameCol]
									INNER JOIN 
										Point pt WITH (NOLOCK)
									ON 
										pt.PointDescription = CONCAT(tb.[NameCol],'-',tb.[NumCol])
										AND 
										pt.PointFlag = 0
								WHERE 
									gf.UpdateFlag = 0 
									AND 
									gf.RowStatus = 1 
									AND 
									pt.RowStatus = 1 
									AND 
									tb.[NumCol] = 1
								GROUP BY pt.IdPoint,pt.PointDescription,gf.IdGeofence, tb.NameMicroZones, tb.NumCol, tb.NameCol


				COMMIT TRANSACTION;
				SELECT 'Datos cargados exitosamente' AS message
				SELECT *FROM Geofence WITH (NOLOCK)


			END TRY
		    BEGIN CATCH

			SELECT
				'Error al cargar los datos' AS message

			ROLLBACK TRANSACTION;

			END CATCH;

					
END
