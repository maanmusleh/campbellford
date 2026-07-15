pageextension 54003 "CFS IWX POS Posted Sales Lines" extends "IWX POS Posted Sales Lines"
{
    layout
    {
        movefirst(Group; "Created Date")

        moveafter("Sales Description"; "Qty. Invoiced")




        movelast(Group; "Sales Type")
        movelast(Group; "Shipping No.")
        movelast(Group; "Document Type")
        movelast(Group; "Document No.")


    }
    trigger OnOpenPage()
    begin
        Rec.SetCurrentKey("Created Date");
        Rec.Ascending(false);
    end;
}
