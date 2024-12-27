CREATE NONCLUSTERED INDEX [IDX_DeliveryOrder_Order_Number_Customer]
    ON [dbo].[DeliveryOrder]([Order_Number] ASC, [IdCustomer] ASC, [Preparation_Date] ASC);