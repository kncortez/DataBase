USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[sps_get_linehauls_by_service]    Script Date: 9/08/2021 17:08:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sps_get_linehauls_by_service] 
@IdRoute AS NVARCHAR(50) = 99999,
@DateOfRoute DATE


AS
BEGIN
	DECLARE @ValidateOperation BIGINT = 0
	DECLARE @RowUpdated INT
	DECLARE @ExisteRuta INT
	DECLARE @HUB_Destino INT
	DECLARE @IdRouteASG INT
	DECLARE @ExisteServicio INT
	DECLARE @IdServiceManagement INT
	DECLARE @ExistePiezaPorServicio INT
	DECLARE @ItemsTable AS TABLE (
		Guide_Number INT
	)

	
	BEGIN
		
			SET @IdRouteASG = (SELECT
						ra.IdRouteAssigment
					FROM RouteAssigment ra
					WHERE ra.IdRoute = @IdRoute
					AND ra.DateOfRoute = @DateOfRoute)


			SELECT (SELECT COUNT(1) FROM  ServiceManagement sm
						WHERE sm.IdPuRouteAssigment = @IdRouteASG ) contador,
							sm.IdServiceManagement
						FROM ServiceManagement sm
						WHERE sm.IdPuRouteAssigment = @IdRouteASG 
						
	END
END
