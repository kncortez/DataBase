
-- =============================================
-- Author:		<Cristian Azurdia>
-- Create date: <2024-04-25>
-- Description:	<Devuelve el listado de Direcciones asiganadas a una cuenta>
-- =============================================

CREATE PROCEDURE [dbo].[spws_get_daily_route_bnhl]
    @Token VARCHAR(200) = '',
    @IdCourier BIGINT,
    @DateRoute DATE
AS
BEGIN
    SELECT 1;
END;