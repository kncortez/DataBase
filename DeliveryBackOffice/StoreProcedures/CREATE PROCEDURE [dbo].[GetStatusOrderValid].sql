USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[GetRoutePreparationDetail]    Script Date: 18/01/2022 13:13:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Oscar, Morales>
-- Create date: <2022-01-18>
-- Description:	<Válida si el estado que se le asignará a una guía es correcto.>
-- =============================================
CREATE PROCEDURE [dbo].[GetStatusOrderValid] @GuideSerie NVARCHAR(2),
@GuideNumber INT,
@StatusOrderId TINYINT
AS
BEGIN

	DECLARE @GuideStatusOrderId TINYINT = (SELECT TOP 1
			dod.StatusOrderId
		FROM DeliveryOrderDetail dod
		WHERE dod.Guide_Serie = @GuideSerie
		AND dod.Guide_Number = @GuideNumber
		ORDER BY dod.DateCreated DESC)

	--Estados de finalización (Entregado, Entregado en Express center)
	IF @GuideStatusOrderId = 5
		OR @GuideStatusOrderId = 22
		--Solo pueden pasar a COD Liquidado o COD PAGADO
		IF @StatusOrderId = 24
			OR @StatusOrderId = 25
			SELECT
				1 StatusCode
			   ,'Estado válido.' Description
		ELSE
			SELECT
				0 StatusCode
			   ,'La guía se encuentra en estado Entregada.' Description
	--COD Liquidado
	ELSE
	IF @GuideStatusOrderId = 24
		--Solo puede pasar a COD pagado
		IF @StatusOrderId = 25
			SELECT
				1 StatusCode
			   ,'Estado válido.' Description
		ELSE
			SELECT
				0 StatusCode
			   ,'La guía se encuentra en estado COD Liquidado.' Description
	--COD Pagado
	ELSE
	IF @GuideStatusOrderId = 25
		--Solo puede pasar a COD Liquidado
		IF @StatusOrderId = 24
			SELECT
				1 StatusCode
			   ,'Estado válido.' Description
		ELSE
			SELECT
				0 StatusCode
			   ,'La guía se encuentra en estado COD Pagado.' Description
	--Si se anulará la guía o se marca como paquete extraviado, paquete retenido, retenido o en revisión es válido en cualquier estado
	ELSE
	IF @StatusOrderId = 7
		OR @StatusOrderId = 27
		OR @StatusOrderId = 26
		OR @StatusOrderId = 28
		OR @StatusOrderId = 13
		SELECT
			1 StatusCode
		   ,'Estado válido.' Description
	--ANULADO
	ELSE
	IF @GuideStatusOrderId = 7
		SELECT
			0 StatusCode
		   ,'La guía se encuentra en estado Anulado.' Description
	--Devuelto en Express Center
	ELSE
	IF @GuideStatusOrderId = 23
		SELECT
			0 StatusCode
		   ,'La guía se encuentra en estado Devuelto en Express Center.' Description
	--Paquete extraviado
	ELSE
	IF @GuideStatusOrderId = 27
		SELECT
			0 StatusCode
		   ,'La guía se encuentra en estado Paquete Extraviado.' Description
	--Devuelto
	ELSE
	IF @GuideStatusOrderId = 14
		SELECT
			0 StatusCode
		   ,'La guía se encuentra en estado Devuelto.' Description
	--Retornado a Origen
	ELSE
	IF @GuideStatusOrderId = 6
		SELECT
			0 StatusCode
		   ,'La guía se encuentra en estado Retornado a Origen.' Description
	--En revisión
	ELSE
	IF @GuideStatusOrderId = 13
		SELECT
			0 StatusCode
		   ,'La guía se encuentra en estado En revisión.' Description
	--Paquete retenido
	ELSE
	IF @GuideStatusOrderId = 26
		SELECT
			0 StatusCode
		   ,'La guía se encuentra en estado Paquete Retenido.' Description
	--Retenido
	ELSE
	IF @GuideStatusOrderId = 28
		SELECT
			0 StatusCode
		   ,'La guía se encuentra en estado Retenido.' Description
	--Generado
	ELSE
	IF @GuideStatusOrderId = 15
		--Puede pasar a Recibido en Express Center, Solicitado
		IF @StatusOrderId = 21
			OR @StatusOrderId = 1
			SELECT
				1 StatusCode
			   ,'Estado válido.' Description
		ELSE
			SELECT
				0 StatusCode
			   ,'La guía se encuentra en estado Generado.' Description
	--Solicitado
	ELSE
	IF @GuideStatusOrderId = 1
		--Puede pasar a Recibido en Express Center o Progamado para Recolección
		IF @StatusOrderId = 21
			OR @StatusOrderId = 16
			SELECT
				1 StatusCode
			   ,'Estado válido.' Description
		ELSE
			SELECT
				0 StatusCode
			   ,'La guía se encuentra en estado Solicitado.' Description
	--Programado para recolección
	ELSE
	IF @GuideStatusOrderId = 16
		--Puede pasar a Recibido en Express Center o Recolectado
		IF @StatusOrderId = 21
			OR @StatusOrderId = 2
			SELECT
				1 StatusCode
			   ,'Estado válido.' Description
		ELSE
			SELECT
				0 StatusCode
			   ,'La guía se encuentra en estado Programado para Recolección.' Description
	--Recolectado
	ELSE
	IF @GuideStatusOrderId = 2
		--Puede pasar a Entregado en Express Center, Devuelto en Express Center, Arribó a las instalaciones
		IF @StatusOrderId = 22
			OR @StatusOrderId = 23
			OR @StatusOrderId = 11
			SELECT
				1 StatusCode
			   ,'Estado válido.' Description
		ELSE
			SELECT
				0 StatusCode
			   ,'La guía se encuentra en estado Recolectado.' Description
	--Arribó a las Instalaciones
	ELSE
	IF @GuideStatusOrderId = 11
		--Puede pasar a En Inventario, Devuelto en Express Center, Asignado, En tránsito, Programado para devolución
		--Programado para entrega, 
		IF @StatusOrderId = 10
			OR @StatusOrderId = 23
			OR @StatusOrderId = 30
			OR @StatusOrderId = 19
			OR @StatusOrderId = 17
			OR @StatusOrderId = 3
			SELECT
				1 StatusCode
			   ,'Estado válido.' Description
		ELSE
			SELECT
				0 StatusCode
			   ,'La guía se encuentra en estado Arribó a las instalaciones.' Description
	--Programado para entrega
	ELSE
	IF @GuideStatusOrderId = 3
		--Puede pasar a En ruta, Devuelto express center, Entregado en express center,
		IF @StatusOrderId = 4
			OR @StatusOrderId = 21
			OR @StatusOrderId = 22
			SELECT
				1 StatusCode
			   ,'Estado válido.' Description
		ELSE
			SELECT
				0 StatusCode
			   ,'La guía se encuentra en estado Programado para entrega.' Description
	--En ruta
	ELSE
	IF @GuideStatusOrderId = 4
		--Puede pasar a Retornado a Forza, Entregado, Traslado a Express Center, Intento de entrega Fallida
		IF @StatusOrderId = 8
			OR @StatusOrderId = 5
			OR @StatusOrderId = 20
			OR @StatusOrderId = 12
			SELECT
				1 StatusCode
			   ,'Estado válido.' Description
		ELSE
			SELECT
				0 StatusCode
			   ,'La guía se encuentra en estado En ruta.' Description
	--Recibido en Express center
	ELSE
	IF @GuideStatusOrderId = 21
		--Puede pasar a Entregado en express center, Devuelto en express center, En inventario, Arribó a las instalaciones
		IF @StatusOrderId = 22
			OR @StatusOrderId = 23
			OR @StatusOrderId = 10
			OR @StatusOrderId = 11
			SELECT
				1 StatusCode
			   ,'Estado válido.' Description
		ELSE
			SELECT
				0 StatusCode
			   ,'La guía se encuentra en estado Recibido en Express Center.' Description
	--Reenviado a Express Center
	ELSE
	IF @GuideStatusOrderId = 20
		--Puede pasar a Entregado en Express Center, Devuelto en Express Center
		IF @StatusOrderId = 22
			OR @StatusOrderId = 23
			SELECT
				1 StatusCode
			   ,'Estado válido.' Description
		ELSE
			SELECT
				0 StatusCode
			   ,'La guía se encuentra en estado Reenviado a Express Center.' Description
	--Programado para Devolución
	ELSE
	IF @GuideStatusOrderId = 17
		--Puede pasar a En ruta para Devolución, Devuelto express center
		IF @StatusOrderId = 18
			OR @StatusOrderId = 23
			SELECT
				1 StatusCode
			   ,'Estado válido.' Description
		ELSE
			SELECT
				0 StatusCode
			   ,'La guía se encuentra en estado Programado para Devolución.' Description
	--En Ruta para Devolución
	ELSE
	IF @GuideStatusOrderId = 18
		--Puede pasar a Devuelto, Devuelto express center
		IF @StatusOrderId = 14
			OR @StatusOrderId = 23
			SELECT
				1 StatusCode
			   ,'Estado válido.' Description
		ELSE
			SELECT
				0 StatusCode
			   ,'La guía se encuentra en estado En Ruta para Devolución.' Description
	--En Tránsito
	ELSE
	IF @GuideStatusOrderId = 19
		--Puede pasar a Arribó a las instalaciones
		IF @StatusOrderId = 11
			SELECT
				1 StatusCode
			   ,'Estado válido.' Description
		ELSE
			SELECT
				0 StatusCode
			   ,'La guía se encuentra en estado En Tránsito.' Description
	--Intento de entrega fallida
	ELSE
	IF @GuideStatusOrderId = 12
		--Puede pasar a Intento de entrega fallida, Devuelto en Express center, Arribó a las instalaciones, En inventario
		--Entregado en express center, 
		IF @StatusOrderId = 12
			OR @StatusOrderId = 22
			OR @StatusOrderId = 10
			OR @StatusOrderId = 23
			OR @StatusOrderId = 11
			SELECT
				1 StatusCode
			   ,'Estado válido.' Description
		ELSE
			SELECT
				0 StatusCode
			   ,'La guía se encuentra en estado Intento de Entrega Fallida.' Description
	--En inventario
	ELSE
	IF @GuideStatusOrderId = 10
		--Puede pasar a Entregado en Express Center, Programado para Devolución, Devuelto en Express center
		-- Programado para entrega
		IF @StatusOrderId = 22
			OR @StatusOrderId = 17
			OR @StatusOrderId = 23
			OR @StatusOrderId = 3
			SELECT
				1 StatusCode
			   ,'Estado válido.' Description
		ELSE
			SELECT
				0 StatusCode
			   ,'La guía se encuentra en estado En Inventario.' Description
	--Retornado a Forza
	ELSE
	IF @GuideStatusOrderId = 8
		--Puede pasar a Devuelto en Express center, Progamado para Entrega, Programado para Devolución
			--En Inventario
		IF @StatusOrderId = 23
			OR @StatusOrderId = 3
			OR @StatusOrderId = 17
			OR @StatusOrderId = 10
			SELECT
				1 StatusCode
			   ,'Estado válido.' Description
		ELSE
			SELECT
				0 StatusCode
			   ,'La guía se encuentra en estado Retornado a Forza.' Description
	--Asignado
	ELSE
	IF @GuideStatusOrderId = 30
		--Puede pasar a En ruta
		IF @StatusOrderId = 4
			SELECT
				1 StatusCode
			   ,'Estado válido.' Description
		ELSE
			SELECT
				0 StatusCode
			   ,'La guía se encuentra en estado Asignado.' Description
	--Entrega parcial
	ELSE
	IF @GuideStatusOrderId = 9
		--De momento no se valida
		SELECT
			1 StatusCode
		   ,'Estado válido.' Description
	--Reenviado al HUB Origen para Devolución
	ELSE
	IF @GuideStatusOrderId = 29
		--De momento no se valida
		SELECT
			1 StatusCode
		   ,'Estado válido.' Description

END