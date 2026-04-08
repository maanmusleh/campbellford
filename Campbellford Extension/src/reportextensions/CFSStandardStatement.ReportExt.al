reportextension 54000 "CFS Standard Statement" extends "Standard Statement"
{
    dataset
    {
        modify(Customer)
        {
            trigger OnBeforePreDataItem()
            begin
                Customer.SetCurrentKey("Search Name");
                Customer.SetAscending("Search Name", true);
            end;
        }
    }
}
