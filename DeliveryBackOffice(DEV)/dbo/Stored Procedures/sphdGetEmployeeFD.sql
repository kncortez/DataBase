-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <2021-10-15>
-- Description:	<Obtiene todos los empleados registrados de Forza Delivery>
-- =============================================
CREATE PROCEDURE [dbo].[sphdGetEmployeeFD]
	-- Add the parameters for the stored procedure here
	@CodeEmployee AS VARCHAR(50) = 'all',
	@IdCountry AS VARCHAR(2) = 'GT'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT  epl.IdEmployee [IdValue],  
			epl.CodeEmployee + ' - ' + UPPER(epl.FirstName) + ' '+ UPPER(epl.SecondName) + ' ' + UPPER(epl.LastName1) + ' ' + UPPER(epl.LastName2) AS [NameValue] ,
			CASE epl.IdCountry WHEN 'GX' THEN 'GT' ELSE epl.IdCountry END [IdFilter], 
			p.EPH_Photo   [Photo],
			epl.FirstName [FirstName],
			epl.LastName1 [LastName],
			epl.DateBrith [DateBirth],
			epl.DPI [DPI],
			epl.Sex [Gender],
			CASE epl.IdNationality	WHEN 1 THEN 'GT' 
									WHEN 2 THEN 'HN' 
									WHEN 3 THEN 'NC' 
									WHEN 4 THEN 'PA' 
									WHEN 5 THEN 'US' 
									WHEN 6 THEN 'SV' 
									WHEN 7 THEN 'MX' 
									WHEN 8 THEN 'CO'
									WHEN 9 THEN 'CR'
									 ELSE 'GT'
			END [Nationality],
			epl.Email,
			epl.CodeEmployee [CodeEmployee],
			(SELECT TOP(1) UPPER(job.PRM_JOB_Name) FROM DenariusDesktop_Dev.dbo.PRM_Job job WHERE job.PRM_JOB_IdJob = epl.IdJob ORDER BY epl.IdEmployee) [WorkEmployee], 
			epl.CellPhone [ContactEmployee]
			FROM    DenariusDesktop_Dev.dbo.LGT_INF_Employee epl 
			LEFT OUTER JOIN DenariusDesktop_Dev.dbo.PRM_Employee_photo p on p.EPH_IdEmployee = epl.IdEmployee
			WHERE   (@CodeEmployee = 'all' OR epl.CodeEmployee = @CodeEmployee)
			AND (epl.IdCountry = IIF(@IdCountry = 'GT', 'GX', @IdCountry))
			AND epl.StatusJob = 1
			AND epl.Employer IN (30) --FORZA DELIVERY
END
