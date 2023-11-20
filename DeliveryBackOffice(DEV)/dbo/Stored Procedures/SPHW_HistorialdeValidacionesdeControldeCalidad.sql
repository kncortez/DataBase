
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2023-11-17>
-- Description:	<Description,Obtener URL de reporte de historial de incdiencias de control de calidad>
-- =============================================
CREATE PROCEDURE [SPHW_HistorialdeValidacionesdeControldeCalidad]
	
AS
BEGIN
	
	SET NOCOUNT ON;

     SELECT 200 IdResult,
                   [Name] Message,
                   Value 'URL'
				   FROM ConfigParams
            WHERE Name = 'HistorialdeValidacionesdeControldeCalidad';
END
GO
