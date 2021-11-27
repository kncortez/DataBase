-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <2021-10-15>
-- Description:	<Obtiene todos los empleados registrados de Forza Delivery>
-- =============================================
CREATE PROCEDURE sphdGetEmployeeFD
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
			epl.Email
			FROM    DenariusDesktop_Dev.dbo.LGT_INF_Employee epl 
			LEFT OUTER JOIN DenariusDesktop_Dev.dbo.PRM_Employee_photo p on p.EPH_IdEmployee = epl.IdEmployee
			WHERE   (@CodeEmployee = 'all' OR epl.CodeEmployee = @CodeEmployee)
			AND (epl.IdCountry = IIF(@IdCountry = 'GT', 'GX', @IdCountry))
			AND epl.StatusJob = 1
			AND epl.Employer IN (30) --FORZA DELIVERY
END
GO
