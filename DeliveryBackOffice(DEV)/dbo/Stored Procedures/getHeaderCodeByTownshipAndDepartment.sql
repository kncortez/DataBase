 -- =============================================
-- Author:		<Tito Garcia>
-- Create date: <2025-01-20>
-- Description:	<Retorna el headerCode y el Id de un municipio>
-- =============================================
CREATE PROCEDURE [dbo].[getHeaderCodeByTownshipAndDepartment]
	@Township AS NVARCHAR(50),
	@Department AS NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT IdTownship, HeaderCode
    FROM [DeliveryBackOffice].[dbo].[Township] WITH (NOLOCK)
    WHERE DeliveryBackOffice.dbo.FnClearString(TownshipName) = DeliveryBackOffice.dbo.FnClearString(@Township)
		AND TownshipStatus = 1
		AND IdProvince =
		(
			SELECT IdProvince
			FROM [DeliveryBackOffice].[dbo].[Province]
			WHERE DeliveryBackOffice.dbo.FnClearString(ProvinceName) = DeliveryBackOffice.dbo.FnClearString(@Department)
		)
END;