-- =============================================
-- Author:		<Eduardo, Lopez>
-- Create date: <2023-07-31>
-- Description:	<Obtiene dato de monto minimo permitido de COD.>
-- =============================================
CREATE PROCEDURE [dbo].[get_minCOD]
AS

DECLARE @MinCOD INT = 0;
BEGIN
 SET @MinCOD =  (SELECT Value FROM ConfigParams WHERE Name = 'MinimumCODAmount')
 SELECT @MinCOD AS MinCOD
END