-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-12-27>
-- Description:	<Método para registro de uso de membresía de cliente por parte de afiliados>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_RegistrationCustomerMembershipByAffiliates]
@IdMembership AS INT,
@Idaffiliate AS INT,
@OriginalAmountOfConsumption AS Decimal(18,2),
@FinalAmountAfterApplyingDiscount AS Decimal(18,2),
@InvoiceIdentifier AS nvarchar(200)='',
@Token nvarchar(50)
AS
BEGIN


DECLARE @CatMembershipId AS INT =(SELECT  CatMembershipId FROM [dbo].[Membership] WHERE IdMembership = @IdMembership)
DECLARE @Affiliate AS INT=(Select AffiliateId From [dbo].[RegisterUserByAffiliate] WHERE RegisterUserId=@Idaffiliate)
BEGIN TRANSACTION
BEGIN TRY

		INSERT INTO [dbo].[MembershipUsageByAffiliate] 
		(
		 MembershipId,	
		 AffiliateId,	
		 InvoiceAuthorization,
		 Amount,
		 DiscountValueType,	
		 DiscountValue,
		 DiscountApplied,
		 FinalAmount,	
		 RowStatus,	
		 DateCreated,
		 TokenCreated
		 )
		 VALUES
		 (
		  @IdMembership,
		  @Affiliate,
		  @InvoiceIdentifier,
		  @OriginalAmountOfConsumption,
		  (SELECT DiscountValueType FROM  [dbo].[MembershipAffiliateDiscount] WHERE CatMembershipId = @CatMembershipId AND AffiliateId = @Affiliate ),
		  (SELECT DiscountValue     FROM  [dbo].[MembershipAffiliateDiscount] WHERE CatMembershipId = @CatMembershipId AND AffiliateId = @Affiliate),
		  @OriginalAmountOfConsumption - @FinalAmountAfterApplyingDiscount,
		  @FinalAmountAfterApplyingDiscount,
		  1,
		  GETDATE(),
		  @TOKEN

		 )

	 COMMIT TRANSACTION
	 SELECT Result = 1

END TRY
BEGIN CATCH
	 ROLLBACK TRANSACTION
	 SELECT Result = 0, ERROR_MESSAGE() AS 'Description'
END CATCH

END