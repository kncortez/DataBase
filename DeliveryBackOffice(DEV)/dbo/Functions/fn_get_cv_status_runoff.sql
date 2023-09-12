


--DROP FUNCTION [dbo].[fn_get_cv_status_runoff]
/* CONTROL DE ESTADOS OPERATIVOS PARA LOS CENTROS DE VOTACION, NO PARA EL PARQUE DE LA INDUSTRIA */
CREATE FUNCTION [dbo].[fn_get_cv_status_runoff]
(
    @GuideSerie NVARCHAR(2),
    @GuideNumber INT
)
RETURNS NVARCHAR(60)
AS
BEGIN
    DECLARE @result NVARCHAR(60); -- for function result
	DECLARE @deadline DATETIME = '2023-08-20 18:00'

    -- checkpoint information storage based on guide serie and guide number
    DECLARE @recordFound TABLE
    (
        CheckPointCode INT NOT NULL,
        CheckPointDateTime DATETIME NOT NULL
    );
    -- checkpoint information retrieve based on guide serie and guide number
    DECLARE @StatusCode INT;
    DECLARE @StatusDateTime DATETIME;

    -- Status 1 = Solicitado
    DECLARE @msgSolicitado NVARCHAR(60) = N'Servicio programado';
    -- Status 2 = Recolectado
    DECLARE @msgRecolectado NVARCHAR(60) = N'Servicio programado';
    -- Status 11 = Arribó a Instalaciones
    DECLARE @msgArribo NVARCHAR(60) = N'Servicio programado';
    -- Status 4 = En Ruta
    DECLARE @msgEnRuta NVARCHAR(60) = N'Servicio programado';
    -- Status 5 = Entregado
    DECLARE @msgEntregado NVARCHAR(60) = N'Cajas entregadas a Centro de Votación';
    -- Status 32 = Declarado para devolución
    DECLARE @msgDeclaradoDevolucion NVARCHAR(60) = N'Cajas entregadas a Centro de Votación';
    -- Status 2 = Recolectado (devolución)
    DECLARE @msgRecolectado2 NVARCHAR(60) = N'Cajas recolectadas en Centro de Votación';
    -- Status 14 = Devuelto
    DECLARE @msgDevuelto NVARCHAR(60) = N'Cajas recolectadas en Centro de Votación';

    INSERT INTO @recordFound
    SELECT TOP (1)
        --so.OrderDescription,
           dod.StatusOrderId,
           dod.DateCreated
    FROM dbo.DeliveryOrderDetail dod WITH (NOLOCK)
    --INNER JOIN dbo.StatusOrder so WITH (NOLOCK)
    --ON so.StatusOrderId = dod.StatusOrderId
    --AND so.RowStatus = 1
    WHERE dod.Guide_Serie = @GuideSerie
          AND dod.Guide_Number = @GuideNumber
    ORDER BY dod.DateCreated DESC;

    SET @StatusCode =
    (
        SELECT TOP (1) CheckPointCode FROM @recordFound
    );
    SET @StatusDateTime =
    (
        SELECT TOP (1) CheckPointDateTime FROM @recordFound
    );

    SET @result = CASE @StatusCode
                      WHEN 1 THEN
                          @msgSolicitado
                      WHEN 2 THEN
    --(IIF(DATEPART(HOUR, @StatusDateTime) >= 18, @msgRecolectado2, @msgRecolectado))
	(IIF(@StatusDateTime >= @deadline, @msgRecolectado2, @msgRecolectado))
                      WHEN 11 THEN
                          @msgArribo
                      WHEN 4 THEN
                          @msgEnRuta
                      WHEN 5 THEN
                          @msgEntregado
                      WHEN 32 THEN
                          @msgDeclaradoDevolucion
                      WHEN 14 THEN
                          @msgDevuelto
                      -- ninguno de los códigos anteriores NO es válido
                      ELSE
                          'N/A'
                  END;

    RETURN @result;

END;