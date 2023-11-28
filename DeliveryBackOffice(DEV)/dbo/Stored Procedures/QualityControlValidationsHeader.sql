
-- =============================================
-- Author:		<Author,Edelman Vásquez>
-- Create date: <Create Date, 2023-11-16>
-- Description:	<Description,Cabecera de historial de validaciones de incidencias>
-- =============================================
Create PROCEDURE [dbo].[QualityControlValidationsHeader]
 @StartDate DATE,
 @EndDate DATE
AS
BEGIN

Select
	CONVERT(NVARCHAR(10),@StartDate,110) AS StartDate,
	CONVERT(NVARCHAR(10),@EndDate,110)  AS EndDate,
    COUNT(DISTINCT CASE WHEN COI.IsConfirmed = 0 AND COI.IsDenied = 0 AND COI.StatusOrderId = 45 THEN DA.Guide_Number END) AS UnprocessedIncidentCount,
    COUNT(DISTINCT CASE WHEN COI.StatusOrderId = 50 AND COI.IsConfirmed = 1 THEN DA.Guide_Number END) AS ProcessedIncidentsCount
	From
	ConfirmationOfIncidence COI WITH (NOLOCK) 
	INNER JOIN 
	DeliveryAttempt DA WITH (NOLOCK) ON DA.ConfirmationOfIncidenceId = COI.IdConfirmationOfIncidence
	WHERE
    CONVERT(DATE, COI.DateCreated) BETWEEN @StartDate AND @EndDate

    
END

