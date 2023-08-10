CREATE NONCLUSTERED INDEX [IDX_RowStatus_DateCreated DESC]
    ON [dbo].[Cost]([RowStatus] ,[DateCreated] DESC)
    INCLUDE([IdCost], [ProductNumber],  [GuideSerie], [GuideNumber]);