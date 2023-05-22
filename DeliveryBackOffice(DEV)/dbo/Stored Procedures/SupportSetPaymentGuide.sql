
create procedure [dbo].[SupportSetPaymentGuide]
    @GuideSerie [varchar](2)
  , @GuideNumber int
  , @Amount decimal(12, 2)
  , @Token nvarchar(50)
as
begin

    begin try
        begin transaction;

        update dbo.Cost
        set TotalAmountPaid = @Amount
          , TokenUpdated = @Token
          , DateUpdated = getdate()
        where GuideSerie = @GuideSerie
              and GuideNumber = @GuideNumber;

       

		
		 commit;

		 SELECT * FROM dbo.Cost
		 where GuideSerie =@GuideSerie  and GuideNumber = @GuideNumber

    end try
    begin catch
        rollback transaction;

	SELECT 'Error'

    end catch;

end;