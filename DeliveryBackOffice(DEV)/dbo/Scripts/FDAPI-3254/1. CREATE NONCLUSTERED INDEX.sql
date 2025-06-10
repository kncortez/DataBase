CREATE NONCLUSTERED INDEX [IDX_DeliveryOrder_Ticket_Number_Customer]
    ON [dbo].[DeliveryOrder]([Ticket_Number] ASC, [IdCustomer] ASC, [Preparation_Date] ASC);