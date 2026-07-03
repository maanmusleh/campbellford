pageextension 54004 "CFS IWX POS Posted Sales Lines" extends "IWX POS Posted Sales Lines"
{

    layout
    {

        movefirst(Group; "Created Date")
        moveafter("Sales Description"; "Qty. Shipped")
        moveafter("Qty. Invoiced"; "Unit of Measure Code")
        moveafter("Unit Price"; "Unit of Measure Code")
        moveafter("Line Amount Excl. Tax"; "Unit Price")
        movelast(Group; "Document Type")
        movelast(Group; "Shipping No.")
        movelast(Group; "Sales Type")
        movelast(Group; "Document No.")



    }

    trigger OnOpenPage()
    begin
        Rec.SetCurrentKey("Created Date", "Sell-to Customer No.", "Sell-to Contact No.", "Sales Type");
        Rec.SetAscending("Created Date", false);
    end;


}
