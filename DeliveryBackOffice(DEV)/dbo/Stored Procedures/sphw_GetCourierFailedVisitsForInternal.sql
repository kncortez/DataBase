-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-11-25>
-- Description:	<Obtiene información de visitas fallidas de couriers para pantalla de dashboard de visitas fallidas de usuarios internos de operaciones>
-- =============================================
CREATE PROCEDURE [dbo].[sphw_GetCourierFailedVisitsForInternal]
	-- Add the parameters for the stored procedure here
	@StartDate DATE,
	@FinishDate DATE,
	@UserId BIGINT,
	@CourierId INT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
	
		SELECT
			X.ID CourierId
		   ,X.CourierName CourierName
		   ,SUM(X.Guide) [Services]
		   ,SUM(X.Success) Success
		   ,SUM(X.Incidence) Incidence
		   ,SUM(X.FailedVisits) FailedVisits
		FROM (SELECT
				sr.ID
			   ,CONCAT(sr.First_Name, ' ', sr.Last_Name) CourierName
			   ,SUM(1) Guide
			   ,SUM(CASE
					WHEN da.Delivered = 1 THEN 1
					ELSE 0
				END) Success
			   ,SUM(CASE
					WHEN da.Delivered = 1 THEN 0
					ELSE 1
				END) Incidence
			   ,SUM(CASE
					WHEN ctcoi.IdCatTypeConfirmationOfIncidence IS NOT NULL AND
						ctcoi.[Name] = 'Visita Fallida' THEN 1
					ELSE 0
				END) FailedVisits
			FROM DeliveryAttempt da WITH (NOLOCK)
			INNER JOIN SenderReceiver sr WITH (NOLOCK)
				ON da.ID_Courier = sr.ID
			LEFT JOIN ConfirmationOfIncidence coi WITH (NOLOCK)
				ON da.ConfirmationOfIncidenceId = coi.IdConfirmationOfIncidence
			LEFT JOIN CatTypeConfirmationOfIncidence ctcoi WITH (NOLOCK)
				ON coi.CatTypeConfirmationOfIncidenceId = ctcoi.IdCatTypeConfirmationOfIncidence
			WHERE @FinishDate >= @StartDate
			AND CAST(da.Date_Created AS DATE) >= @StartDate
			AND CAST(da.Date_Created AS DATE) <= @FinishDate
			AND (@CourierId = 0
			OR @CourierId = sr.ID)
			GROUP BY sr.ID
					,sr.First_Name
					,sr.Last_Name
					,da.Guide_Serie
					,da.Guide_Number
					,da.Delivered
					,ctcoi.IdCatTypeConfirmationOfIncidence
					,ctcoi.[Name]) X
			GROUP BY X.ID
					,X.CourierName
			-- Falta agregar validación que el @UserId tenga asignado el courier
	END TRY
	BEGIN CATCH
		SELECT
			0 'StatusCode'
		   ,ERROR_MESSAGE() 'Description'
	END CATCH
END