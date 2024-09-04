
-- =============================================
-- Author:		<Author,Edelman Vásquez>
-- Create date: <Create Date, 2023-11-16>
-- Description:	<Description,Cabecera de historial de validaciones de incidencias>
-- =============================================
-- Author:		<Brandon, Pedroza>
-- Modified:	<2024-08-07>
-- Description:	<Se corrige nombre de campos UnprocessedIncident y ProcessedIncidents>
-- =============================================
CREATE PROCEDURE [dbo].[QualityControlValidationsHeader]
 @StartDate DATE,
 @EndDate DATE
AS
BEGIN
set arithabort on;
Select
	CONVERT(NVARCHAR(10),@StartDate,105) AS StartDate,
	CONVERT(NVARCHAR(10),@EndDate,105)  AS EndDate,
    COUNT(CASE WHEN COI.IsConfirmed = 0 and COI.StatusOrderId = 45 and Delivered = 0 THEN DA.Guide_Number END) AS UnprocessedIncident,
    COUNT(CASE WHEN COI.StatusOrderId = 50 AND COI.IsConfirmed = 1 and Delivered = 0 THEN DA.Guide_Number END) AS ProcessedIncidents
	From
	ConfirmationOfIncidence COI WITH (NOLOCK) 
	INNER JOIN 
	DeliveryAttempt DA WITH (NOLOCK) ON DA.ConfirmationOfIncidenceId = COI.IdConfirmationOfIncidence
	WHERE
    CONVERT(DATE, COI.DateCreated) BETWEEN @StartDate AND @EndDate

    
END

