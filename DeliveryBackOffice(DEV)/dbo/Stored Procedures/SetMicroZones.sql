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

			UPDATE pt1
			SET pt1.RowStatus = 0
			FROM dbo.Point pt1 WITH (NOLOCK)
				INNER JOIN GeofencePoint gfp1 WITH (NOLOCK)
				 ON pt1.IdPoint = gfp1.IdPoint
				 INNER JOIN Geofence gfce1 WITH (NOLOCK)
				 ON gfp1.IdGeofence = gfce1.IdGeofence
				INNER JOIN @TblMicroZones tbmz1 
				ON gfce1.GeofenceDescription = tbmz1.NameCol
				WHERE pt1.RowStatus = 1 AND gfp1.RowStatus = 1 AND gfce1.RowStatus = 1 AND gfce1.UpdateFlag = 0
	
			UPDATE gpt
			SET gpt.RowStatus = 0
			FROM dbo.GeofencePoint gpt WITH (NOLOCK)
				INNER JOIN Geofence gfce WITH (NOLOCK)
				 ON gpt.IdGeofence = gfce.IdGeofence
				INNER JOIN @TblMicroZones tbmz2
				ON gfce.GeofenceDescription = tbmz2.NameCol
				WHERE gpt.RowStatus = 1 AND gfce.RowStatus = 1 AND gfce.UpdateFlag = 0


			UPDATE gfc
			SET gfc.RowStatus = 0
			FROM dbo.Geofence gfc WITH (NOLOCK)
				INNER JOIN @TblMicroZones tbmz3
				ON gfc.GeofenceDescription = tbmz3.NameCol
				WHERE gfc.RowStatus = 1 AND gfc.UpdateFlag = 0


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
						,(SELECT SUBSTRING(tbm.NameMicroZones,1,len(tbm.NameMicroZones) - 1))
						,1
						,@Token
						,GETDATE()
						FROM @TblMicroZones tbm 


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
						SELECT DISTINCT
						tbmz.NameMicroZones 	
						,(SELECT CAST ((SUBSTRING(tbmz.MicroZones, CHARINDEX(' ',tbmz.MicroZones)+1, CHARINDEX(' ',tbmz.MicroZones))) AS DECIMAL(15,7)))
						,(SELECT CAST ((SUBSTRING(tbmz.MicroZones, 1, CHARINDEX(' ',tbmz.MicroZones))) AS DECIMAL(15,7)))
						--,(SELECT CAST ((SUBSTRING(tbmz.MicroZones,1,12)) AS DECIMAL(15,7)))
						,1
						,@Token
						,GETDATE()
						,null
						,null
						FROM @TblMicroZones tbmz

				

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
								,IIF((SELECT Max(tb2.NumCol) FROM @TblMicroZones tb2 WHERE tb2.NameCol = tb.NameCol) = tb.NumCol,pt.IdPoint,pt.IdPoint)
								--,IIF((Select Max(tb2.NumCol) from @TblMicroZones tb2 where tb2.NameCol = tb.NameCol) = tb.NumCol,(Select MIN(pt2.IdPoint) FROM Point pt2 where SUBSTRING(pt2.PointDescription,1,len(tb.NameMicroZones)-1) = SUBSTRING(pt.PointDescription,1,len(tb.NameMicroZones)-1)),pt.IdPoint)
								,IIF((Count(SUBSTRING(tb.NameMicroZones,1,len(tb.NameMicroZones) - 1))) =(SUBSTRING(tb.NameMicroZones,len(tb.NameMicroZones),1)),(tb.NumCol),(tb.NumCol))
								,1
								,@Token
								,GETDATE()
								FROM Geofence gf WITH (NOLOCK)
								INNER JOIN @TblMicroZones tb
								ON gf.GeofenceDescription = (SELECT SUBSTRING(tb.NameMicroZones,1,len(tb.NameMicroZones) - 1))
								AND gf.UpdateFlag = 0
								INNER JOIN Point pt WITH (NOLOCK)
								ON pt.PointDescription = tb.NameMicroZones
								AND pt.PointFlag = 0
								WHERE gf.RowStatus = 1 AND pt.RowStatus = 1
								GROUP BY pt.IdPoint,pt.PointDescription,gf.IdGeofence, tb.NameMicroZones, tb.NumCol, tb.NameCol

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
								,IIF((SELECT Max(tb2.NumCol) FROM @TblMicroZones tb2 WHERE tb2.NameCol = tb.NameCol) = tb.NumCol,(SELECT MIN(pt2.IdPoint) FROM Point pt2 WITH (NOLOCK) WHERE SUBSTRING(pt2.PointDescription,1,len(tb.NameMicroZones)-1) = SUBSTRING(pt.PointDescription,1,len(tb.NameMicroZones)-1)AND pt2.RowStatus = 1 AND pt2.PointFlag = 0),pt.IdPoint)
								,IIF((Count(SUBSTRING(tb.NameMicroZones,1,len(tb.NameMicroZones) - 1))) =(SUBSTRING(tb.NameMicroZones,len(tb.NameMicroZones),1)),(tb.NumCol+1),(tb.NumCol+1))
								,1
								,@Token
								,GETDATE()
								FROM Geofence gf WITH (NOLOCK)
								INNER JOIN @TblMicroZones tb
								ON gf.GeofenceDescription = (SELECT SUBSTRING(tb.NameMicroZones,1,len(tb.NameMicroZones) - 1))
								AND gf.UpdateFlag = 0
								INNER JOIN Point pt WITH (NOLOCK)
								ON pt.PointDescription = tb.NameMicroZones
								AND pt.PointFlag = 0
								WHERE gf.RowStatus = 1 AND pt.RowStatus = 1 AND (SELECT MAX(tb2.NumCol) FROM @TblMicroZones tb2 WHERE tb2.NameCol = tb.NameCol) = tb.NumCol
								GROUP BY pt.IdPoint,pt.PointDescription,gf.IdGeofence, tb.NameMicroZones, tb.NumCol, tb.NameCol


			END TRY
		    BEGIN CATCH

			SELECT
				'Error al cargar los datos' AS message

			ROLLBACK TRANSACTION;

			END CATCH;

		IF @@trancount > 0
		BEGIN

			COMMIT TRANSACTION;
			SELECT 'Datos cargados exitosamente' AS message
			SELECT IdGeofence,CountryId,GeofenceDescription, RowStatus FROM Geofence WITH (NOLOCK) WHERE RowStatus = 1 AND UpdateFlag = 0

		END;

					
END