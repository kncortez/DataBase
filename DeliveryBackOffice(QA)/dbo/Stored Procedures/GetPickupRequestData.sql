-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-03-02>
-- Description:	<Recupera información para form NewPickupRequest>
-- =============================================
CREATE PROCEDURE [dbo].[GetPickupRequestData] @GuideSerie NVARCHAR(2),
		@GuideNumber INT
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
		
		DECLARE @Guide VARCHAR(200) = CONCAT(@GuideSerie,@GuideNumber)
		DECLARE @IdCustomer INT
		DECLARE @TypeService VARCHAR(3)
		DECLARE @Segment VARCHAR(MAX)
		DECLARE @NameArticle VARCHAR(100)
		DECLARE @AmountToPay DECIMAL (14,2)
		DECLARE @Address NVARCHAR(1000)
		DECLARE @Exists BIT = 'false'

		DECLARE @TempPrice TABLE
				(	GuideSerie			NVARCHAR (2) null,
					GuideNumber			INT null,
					IsCollect			NVARCHAR (25) null,
					Price				DECIMAL (14,2) null,
					COD					DECIMAL (14,2) null,
					AmountPaid			DECIMAL (14,2) null,
					CODPaid				DECIMAL (14,2) null,
					CODIsPaid			DECIMAL (14,2) null,
					PaymentTime			INT null,
					TimeSequence		INT null,
					FelNumber			NVARCHAR (50) null,
					IsPaid				INT null,
					IsCustomer			INT null,
					ConditionPayment	NVARCHAR(200) null,
					HaveCredit			NVARCHAR (50) null,
					CollectCOD			NVARCHAR (50) null,
					ReturnRate			DECIMAL (14,2) null,
					AmountToPay			DECIMAL (14,2) null,
					CODAmount			DECIMAL (14,2) null,
					ReturnRates			DECIMAL (14,2) null)
		
		INSERT INTO @TempPrice 
		EXEC  [dbo].[spws_get_guide_pending_payment]
			@InGuides = @Guide,
			@InTime = 2,
			@IsReturn = 'FALSE',
			@CodeApp = 'SIFDCECOM300720201459',
			@IdModule = 1,
			@Token = 'SYSTEM'

		SELECT
			@IdCustomer = cu.IdCustomer
		   ,@TypeService = do.TypeService
		   ,@Address = do.Sender_Address
		   ,@AmountToPay = ISNULL(tp.AmountToPay, 0)
		   ,@Exists = 'TRUE'
		FROM DeliveryOrder do
		LEFT JOIN VisitPointClient vpc
			ON do.Sender_ID = vpc.CodeOfReference
		INNER JOIN Customer cu
			ON COALESCE(do.IdCustomer, vpc.CustomerID) = cu.IdCustomer
		LEFT JOIN @TempPrice tp
			ON tp.GuideSerie = do.Guide_Serie
				AND tp.GuideNumber = do.Guide_Number
		WHERE do.Guide_Serie = @GuideSerie
		AND do.Guide_Number = @GuideNumber

		IF @TypeService IS NULL
		SET @TypeService = 'NDD'

		SET @Segment = (SELECT [dbo].[fn_get_segment] (@GuideSerie,@GuideNumber))
	
		IF @Segment IS NULL
			SET @Segment = 'LOC'

		IF @Segment = 'FOR'
			IF @TypeService = 'SDD'
				SET @NameArticle = 'SAME DAY DELIVERY FORANEO'
			ELSE
				SET @NameArticle = 'NEXT DAY DELIVERY FORANEO'
		ELSE
			IF @TypeService = 'SDD'
				SET @NameArticle = 'SAME DAY DELIVERY LOCAL'
			ELSE
				SET @NameArticle = 'NEXT DAY DELIVERY LOCAL'

		IF @Exists = 'TRUE'
			SELECT
				1 [blnResult]
			   ,@IdCustomer [IdCustomer]
			   ,@TypeService [TypeService]
			   ,@NameArticle [NameArticle]
			   ,@AmountToPay [AmountToPay]
			   ,@Address [Address]
		ELSE
			SELECT
				-1 [blnResult]
			   ,CONCAT('La Guía ', @GuideSerie, @GuideNumber, ' no existe en el sistema.') [Description]


	END TRY
	BEGIN CATCH
		SELECT
			0 [blnResult]
		   ,ERROR_NUMBER() [ErrorNumber]
		   ,ERROR_SEVERITY() [ErrorSeverity]
		   ,ERROR_STATE() [ErrorState]
		   ,ERROR_PROCEDURE() [ErrorProcedure]
		   ,ERROR_LINE() [ErrorLine]
		   ,ERROR_MESSAGE() [ErrorMessage];
	END CATCH
END
