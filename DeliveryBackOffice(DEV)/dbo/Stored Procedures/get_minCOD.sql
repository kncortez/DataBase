-- =============================================
-- Author:		<Eduardo, Lopez>
-- Create date: <2023-07-31>
-- Description:	<Obtiene dato de monto minimo permitido de COD.>
-- =============================================
-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <2024-06-26>
-- Description:	<Se agrega filtro de pais>
-- =============================================
CREATE PROCEDURE [dbo].[get_minCOD]
				 @IdCountry NVARCHAR(2) = 'GT'
AS
BEGIN
	SELECT [Value] AS MinCOD 
	FROM ConfigParams WITH (NOLOCK)
	WHERE [Name] = 'MinimumCODAmount' AND IdCountry = @IdCountry
END