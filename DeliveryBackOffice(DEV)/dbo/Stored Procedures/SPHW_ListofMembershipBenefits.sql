-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2023-07-07>
-- Description:	<Description, Descripciones de los beneficios de membresias para notificaciones>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_ListofMembershipBenefits] 
@IdMembership INT 	
AS
BEGIN



     DECLARE @CatMembershipId INT=(Select CatMembershipId From [dbo].[Membership] WITH (NOLOCK) Where IdMembership = @IdMembership);
	
	SET NOCOUNT ON;

		Select ISNULL(MembershipAttributeDescription,'') AS 'Benefits'
			From [dbo].[CatMembershipAttribute] WITH (NOLOCK) 
		Where CatMembershipId = @CatMembershipId 
				And RowStatus = 1


END