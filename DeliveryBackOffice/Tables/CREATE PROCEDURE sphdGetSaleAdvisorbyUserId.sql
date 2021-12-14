SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alberto,Ixchop>
-- Create date: <2021-12-04>
-- Description:	<Obitene una lista de los roles que posee un usuario por medio del idUser>
-- =============================================
CREATE PROCEDURE sphdGetSaleAdvisorbyUserId
	@idUser int
AS
BEGIN
        select 
        	IU.IdUser,
			ius.SaleAdvisorId
        from InternalUser IU 
		INNER join dbo.SaleAdvisorbyUser ius on ius.UserId=IU.IdUser
        where ius.RowStatus=1 and IU.IdUser=@idUser
END
GO



