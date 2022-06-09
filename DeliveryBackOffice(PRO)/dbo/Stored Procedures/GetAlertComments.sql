
-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2021-12-09>
-- Description:	< Obtiene comentarios respecto a una alerta >
-- =============================================
CREATE PROCEDURE [dbo].[GetAlertComments]
	@IdAlert INT
AS
BEGIN

	DECLARE @RolSACID INT = (SELECT TOP 1 RolIdRol FROM [DeliveryBackOffice].[dbo].[CatRol] WHERE UPPER(RolName) = 'SAC')
	DECLARE @RolRDID INT = (SELECT TOP 1 RolIdRol FROM [DeliveryBackOffice].[dbo].[CatRol] WHERE UPPER(RolName) = 'RADIODISPATCH')
	
	SELECT
		ISNULL((
			SELECT TOP 1
				(
					CASE
						WHEN RBUBS.RusIdRol = @RolSACID THEN 'SAC'
						ELSE CONCAT('HUB ', CS.StationName)
					END
				)
			FROM
			[DeliveryBackOffice].[dbo].[RolByUserBySystem] RBUBS
			LEFT JOIN
			[DeliveryBackOffice].[dbo].[CatStation] CS
			ON
			CS.IdStation = RBUBS.StationId
			LEFT JOIN
			[DeliveryBackOffice].[dbo].[CatRol] CR
			ON
			RBUBS.RusIdRol = CR.RolIdRol
			WHERE
			IU.RegisterUserID = RBUBS.RusIdUser
			AND
			RBUBS.RusIdSystem = 2
			AND
			RBUBS.RusRowStatus = 1
			AND
			RBUBS.RusIdRol IN (@RolRDID, @RolSACID)
		),'HUB') 'Rol',
		DOAD.author 'IdAuthor',
		DOAD.username 'Author',
		DOAD.comment 'Comentario',
		DOAD.DateCreated 'DateComment'
	FROM
		[DeliveryBackOffice].[dbo].[DeliveryOrderAlertDetail] DOAD
		JOIN
		[DeliveryBackOffice].[dbo].[DeliveryOrderAlert] DOA
		ON
		DOAD.DeliveryOrderAlertId = DOA.IdDeliveryOrderAlert
		AND
		DOA.RowStatus = 1
		JOIN
		[DeliveryBackOffice].[dbo].[DeliveryOrder] DO
		ON
		DOA.GuideSerie = DO.Guide_Serie
		AND
		DOA.GuideNumber = DO.Guide_Number
		LEFT JOIN
		[DeliveryBackOffice].[dbo].[InternalUser] IU
		ON
		DOAD.author = IU.IdUser
	WHERE
		DOA.IdDeliveryOrderAlert = @IdAlert
	ORDER BY
		DOAD.DateCreated ASC

END
