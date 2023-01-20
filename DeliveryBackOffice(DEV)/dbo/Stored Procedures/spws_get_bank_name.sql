
-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2020-10-27>
-- Description:	<Devuelve el nombre de un banco
--				basado en coincidencia de  nombre>
-- =============================================
-- =============================================
-- Author:		<Edelman, Vásquez>
-- Create date: <2023-01-05>
-- Description:	<Ordenar nombre de bancos de forma Ascendente>
-- =============================================
-- =============================================
-- Author:		<Edelman, Vásquez>
-- Create date: <2023-01-20>
-- Description:	<Agregar Campo tipo Cuenta, máximo caracteres, mínimo caracteres, dígitos de inicio y mensaje de estructura  de cuentas>
-- =============================================
CREATE PROCEDURE  [dbo].[spws_get_bank_name]
	-- Add the parameters for the stored procedure here
	@ValName as nvarchar(100),
	@IdCountry as nvarchar(2) = 'GT'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   select 
	 [Id_bank]
	,[Name]
	,[Acronym]
	,[Description]
	,[Id_country]
	,ISNULL(ABFR.MaximumLength,0) MaximumLength
	,ABFR.StartsWith
	,CBAT.BankAccountType
	,CASE 
	   WHEN ABFR.StartsWith IS NULL THEN
	       'El número de cuenta debe de tener mínimo : ' + CONVERT(VARCHAR,ABFR.MinimumLength)  + ' dígitos y un máximo de  ' + CONVERT(VARCHAR,ABFR.MaximumLength) +' dígitos' 
       WHEN ABFR.MaximumLength IS NULL OR ABFR.MinimumLength IS NULL THEN
	       'El número de cuenta debe iniciar con los dígitos:  ' + ABFR.StartsWith 
	   ELSE
	       'El número de cuenta debe de tener minimo : ' + CONVERT(VARCHAR, ABFR.MinimumLength) + ' dígitos y un máximo de  ' + CONVERT(VARCHAR,ABFR.MaximumLength) + '   dígitos e iniciar con los números :  ' + ABFR.StartsWith 
	END [Message]
	from DeliveryBackOffice.dbo.DeliveryBank  DB WITH  (NOLOCK)
		Inner Join dbo.AccountBankFormatRule ABFR WITH (NOLOCK)
	ON DB.Id_bank = ABFR.DeliveryBankId 
		INNER JOIN dbo.CatBankAccountType CBAT WITH (NOLOCK)
    ON ABFR.CatBankAccountTypeId = CBAT.IdBankAccountType
	where DB.Id_status = 1 
		and (Name like '%' + @ValName + '%' or @ValName = '-1')
		and DB.Id_country = @IdCountry
		--and DB.Id_status = 1
	ORDER BY [Name] ASC

END