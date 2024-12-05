-- =============================================
-- Author:		<Aylinne Recinos>
-- Create date: <2024-04-12>
-- Description:	<Método para guardar el registro del reclamo>
-- =============================================

CREATE PROCEDURE [dbo].[SP_ValidateBankAccNumber]
@TypeAccount INT,
@Bank INT
AS
BEGIN  
    DECLARE @MaximumLength INT;
    DECLARE @MinimumLength INT;
    DECLARE @StartsWith NVARCHAR(150);
    SELECT  @MaximumLength = MaximumLength,
            @MinimumLength = MinimumLength,
            @StartsWith = StartsWith
    FROM [dbo].[AccountBankFormatRule] WITH(NOLOCK) WHERE DeliveryBankId = @Bank AND CatBankAccountTypeId = @TypeAccount

    SELECT  1 AS [StatusCode],
            'Consulta exitosa' AS [Message],
            @MaximumLength AS [MaximumLength],
            @MinimumLength AS [MinimumLength],
            ISNULL(@StartsWith, 'N/A') AS [StartsWith]
END ;