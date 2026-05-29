
-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-02-15>
-- Description:	<Verifica si existen guias
--				 si estan en estado 15 (generado) o 1(solicitado)
--               Si no estan asignadas a otra recolección (IdPickup) >
-- =============================================
-- =============================================
-- Author:		<Edelman, Vásquez>
-- Create date: <2023-03-10>
-- Description:	<Al procesar guías en proceso de recolección desde la CourierApp, si durante el proceso de verificación de montos se detecta una guía en estado terminal, debe impedir el proceso indicando las guías y los estados de estas.>
-- =============================================
-- =============================================  
-- Mofified:    <Brandon, Pedroza>  
-- Create date: <2025-01-13>  
-- Description: <Contenerizacion guias - se agrega parametro para buscar guias de un contenedor asociado o referencia>  
-- =============================================  
CREATE PROCEDURE [dbo].[spws_get_validate_guides_pickup_bnhl2]
    -- Add the parameters for the stored procedure here
    @InGuides NVARCHAR(MAX) = 'FD138515,FD138513,FD13852,FD138514,FD138545,FD135539',
    @IdPickup BIGINT = 120,
    @Token NVARCHAR(50),
    @ReferencesGuide TblReferencesList READONLY,
    @ContainerReferences TblContainerList READONLY,
    @IdCountry NVARCHAR(2) = 'GT'
WITH RECOMPILE
AS
BEGIN
    SET NOCOUNT ON;
    --BEGIN TRY
    PRINT 'ingresa a spws_get_validate_guides_pickup_bnhl2'
        IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL
            DROP TABLE #listGuides;
        IF OBJECT_ID('tempdb.dbo.#ErrorGuides', 'U') IS NOT NULL
            DROP TABLE #ErrorGuides;
        SELECT  'bidcar'



END;