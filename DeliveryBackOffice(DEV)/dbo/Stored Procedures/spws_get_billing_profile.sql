
-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-01-08>
-- Description:	<Devuelve el listado perfiles de facturacion>
-- =============================================
-- =============================================
-- Author:		<Cristian,Suazo>
-- Create date: <2025-03-11>
-- Description:	<Se pasa a tablas el json>
-- =============================================
-- =============================================
-- Author:		<Cristian,Azurdia>
-- Create date: <2025-09-12>
-- Description:	<Actualización de datos favoritos facturación el Salvador>
-- =============================================

CREATE PROCEDURE [dbo].[spws_get_billing_profile]
    -- Add the parameters for the stored procedure here
    @Token VARCHAR(200),
    @IdAccount BIGINT,
    @IdBilling BIGINT = -1
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    DECLARE @IdUser BIGINT = (
                                 SELECT TOP 1
                                     RuaIdUser
                                 FROM dbo.RolByUserByAccount WITH (NOLOCK)
                                 WHERE RuaIdAccount = @IdAccount
                             )

    IF EXISTS
    (
        SELECT TOP 1
            1
        FROM dbo.RolByUserByAccount rua WITH (NOLOCK)
            INNER JOIN dbo.BillingProfile bp WITH (NOLOCK)
                ON bp.BlpIdAccount = rua.RuaIdAccount
        WHERE rua.RuaIdAccount = @IdAccount
              AND rua.RuaIdUser = @IdUser
              AND bp.BlpRowStatus = 1
              AND (
                      bp.BlpIdBilling = @IdBilling
                      OR @IdBilling = -1
                  )
    )
    BEGIN
		SELECT 200 AS IdResult,
               'Datos encontrados' AS [Message]

        SELECT bp.BlpIdAccount AS IdAccount,
               bp.BlpIdBilling AS IdBilling,
               bp.BlpName AS [Name],
               bp.BlpAddress AS [Address],
               bp.BlpTaxId AS TaxId,
               IIF(bp.IsDefault = 1, 'true', 'false') AS IsDefault,
               bp.Inv_type,
               bp.NRC,
               bp.TypeIdentificationDocumentCode,
               bp.IdDocument,
               bp.DistrictId,
               bp.StateId,
               bp.ActivityCode
        FROM dbo.RolByUserByAccount rua WITH (NOLOCK)
            INNER JOIN dbo.BillingProfile bp WITH (NOLOCK)
                ON bp.BlpIdAccount = rua.RuaIdAccount
        WHERE rua.RuaIdAccount = @IdAccount
              AND rua.RuaIdUser = @IdUser
              AND bp.BlpRowStatus = 1
              AND (
                      bp.BlpIdBilling = @IdBilling
                      OR @IdBilling = -1
                  )
    END
    ELSE
    BEGIN

        SELECT 500 AS IdResult,
               'No se econtraron registros' AS [Message]
    END

END